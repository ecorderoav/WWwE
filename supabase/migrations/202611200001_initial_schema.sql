-- What's Wrong with Earth? - Esquema inicial de persistencia
-- T4 - Juan Isidro Caballero Diaz
-- Ejecutado y verificado en el proyecto de desarrollo de Supabase el 25/11/2026.

begin;

create extension if not exists pgcrypto;

create or replace function public.set_updated_at()
returns trigger language plpgsql security invoker set search_path = ''
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create table public.players (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  date_of_birth date not null,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  constraint players_username_length check (char_length(username) between 3 and 24),
  constraint players_username_format check (username ~ '^[A-Za-z0-9_]+$')
);

create unique index players_username_lower_uq on public.players (lower(username));

create table public.player_settings (
  user_id uuid primary key references public.players(user_id) on delete cascade,
  master_volume smallint not null default 80,
  music_volume smallint not null default 80,
  effects_volume smallint not null default 80,
  controls jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default timezone('utc', now()),
  constraint settings_master_volume_range check (master_volume between 0 and 100),
  constraint settings_music_volume_range check (music_volume between 0 and 100),
  constraint settings_effects_volume_range check (effects_volume between 0 and 100),
  constraint settings_controls_object check (jsonb_typeof(controls) = 'object')
);

create table public.moons (
  id bigint generated always as identity primary key,
  code text not null unique,
  name text not null unique,
  display_order smallint not null unique,
  constraint moons_display_order_positive check (display_order > 0)
);

create table public.levels (
  id bigint generated always as identity primary key,
  moon_id bigint not null references public.moons(id) on delete restrict,
  level_number smallint not null,
  name text not null,
  constraint levels_number_positive check (level_number > 0),
  constraint levels_moon_number_uq unique (moon_id, level_number)
);

create table public.player_progress (
  user_id uuid not null references public.players(user_id) on delete cascade,
  level_id bigint not null references public.levels(id) on delete restrict,
  unlocked boolean not null default false,
  completed boolean not null default false,
  completed_at timestamptz,
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (user_id, level_id),
  constraint progress_completed_requires_unlock check (not completed or unlocked)
);

create table public.best_times (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.players(user_id) on delete cascade,
  moon_id bigint not null references public.moons(id) on delete restrict,
  duration_ms bigint not null,
  achieved_at timestamptz not null default timezone('utc', now()),
  constraint best_times_duration_positive check (duration_ms > 0),
  constraint best_times_user_moon_uq unique (user_id, moon_id)
);

create index best_times_ranking_idx on public.best_times (moon_id, duration_ms, achieved_at);

insert into public.moons (code, name, display_order)
values ('moon_1', 'Primera luna', 1), ('moon_2', 'Segunda luna', 2);

insert into public.levels (moon_id, level_number, name)
select m.id, seed.level_number, seed.level_name
from public.moons m
join (
  values
    ('moon_1', 1, 'Nivel 1'), ('moon_1', 2, 'Nivel 2'),
    ('moon_2', 1, 'Nivel 1'), ('moon_2', 2, 'Nivel 2')
) as seed(moon_code, level_number, level_name) on seed.moon_code = m.code;

create or replace function public.validate_minimum_age()
returns trigger language plpgsql security invoker set search_path = ''
as $$
begin
  if new.date_of_birth > (current_date - interval '14 years')::date then
    raise exception 'the player must be at least 14 years old';
  end if;
  if new.date_of_birth < (current_date - interval '120 years')::date then
    raise exception 'invalid date of birth';
  end if;
  return new;
end;
$$;

create trigger players_validate_minimum_age
before insert or update of date_of_birth on public.players
for each row execute function public.validate_minimum_age();

create trigger players_set_updated_at before update on public.players
for each row execute function public.set_updated_at();
create trigger settings_set_updated_at before update on public.player_settings
for each row execute function public.set_updated_at();
create trigger progress_set_updated_at before update on public.player_progress
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
declare
  requested_username text;
  requested_birth_date date;
begin
  requested_username := nullif(trim(new.raw_user_meta_data ->> 'nombre_usuario'), '');
  if requested_username is null
     or char_length(requested_username) not between 3 and 24
     or requested_username !~ '^[A-Za-z0-9_]+$' then
    requested_username := 'jugador_' || substr(new.id::text, 1, 8);
  end if;

  begin
    requested_birth_date := (new.raw_user_meta_data ->> 'fecha_nacimiento')::date;
  exception when others then
    raise exception 'fecha_nacimiento is required in YYYY-MM-DD format';
  end;
  if requested_birth_date is null then
    raise exception 'fecha_nacimiento is required in YYYY-MM-DD format';
  end if;

  insert into public.players (user_id, username, date_of_birth)
  values (new.id, requested_username, requested_birth_date);
  insert into public.player_settings (user_id) values (new.id);
  return new;
exception when unique_violation then
  insert into public.players (user_id, username, date_of_birth)
  values (new.id, 'jugador_' || substr(new.id::text, 1, 8), requested_birth_date);
  insert into public.player_settings (user_id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();

alter table public.players enable row level security;
alter table public.player_settings enable row level security;
alter table public.moons enable row level security;
alter table public.levels enable row level security;
alter table public.player_progress enable row level security;
alter table public.best_times enable row level security;

revoke all on table public.players from anon, authenticated;
revoke all on table public.player_settings from anon, authenticated;
revoke all on table public.moons from anon, authenticated;
revoke all on table public.levels from anon, authenticated;
revoke all on table public.player_progress from anon, authenticated;
revoke all on table public.best_times from anon, authenticated;

grant select, update on table public.players to authenticated;
grant select, update on table public.player_settings to authenticated;
grant select on table public.moons to anon, authenticated;
grant select on table public.levels to anon, authenticated;
grant select, insert, update on table public.player_progress to authenticated;
grant select on table public.best_times to authenticated;

create policy players_read_own on public.players for select to authenticated
using ((select auth.uid()) = user_id);
create policy players_update_own on public.players for update to authenticated
using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy settings_read_own on public.player_settings for select to authenticated
using ((select auth.uid()) = user_id);
create policy settings_update_own on public.player_settings for update to authenticated
using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy moons_public_read on public.moons for select to anon, authenticated using (true);
create policy levels_public_read on public.levels for select to anon, authenticated using (true);
create policy progress_read_own on public.player_progress for select to authenticated
using ((select auth.uid()) = user_id);
create policy progress_insert_own on public.player_progress for insert to authenticated
with check ((select auth.uid()) = user_id);
create policy progress_update_own on public.player_progress for update to authenticated
using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy best_times_read_own on public.best_times for select to authenticated
using ((select auth.uid()) = user_id);

create or replace function public.submit_best_time(
  p_moon_id bigint, p_duration_ms bigint
)
returns public.best_times language plpgsql security definer set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
  result public.best_times;
begin
  if caller_id is null then raise exception 'authentication required'; end if;
  if not exists (select 1 from public.moons where id = p_moon_id) then
    raise exception 'invalid moon';
  end if;
  if p_duration_ms <= 0 then raise exception 'invalid duration'; end if;

  insert into public.best_times (user_id, moon_id, duration_ms)
  values (caller_id, p_moon_id, p_duration_ms)
  on conflict (user_id, moon_id) do update
    set duration_ms = excluded.duration_ms,
        achieved_at = timezone('utc', now())
    where excluded.duration_ms < public.best_times.duration_ms
  returning * into result;

  if result.id is null then
    select * into result from public.best_times
    where user_id = caller_id and moon_id = p_moon_id;
  end if;
  return result;
end;
$$;

revoke all on function public.submit_best_time(bigint, bigint) from public;
grant execute on function public.submit_best_time(bigint, bigint) to authenticated;

create or replace function public.get_leaderboard(p_moon_id bigint default null)
returns table (moon_name text, username text, duration_ms bigint, ranking_position bigint)
language sql stable security definer set search_path = ''
as $$
  select m.name, p.username, bt.duration_ms,
         dense_rank() over (
           partition by bt.moon_id order by bt.duration_ms, bt.achieved_at
         )::bigint
  from public.best_times bt
  join public.players p on p.user_id = bt.user_id
  join public.moons m on m.id = bt.moon_id
  where p_moon_id is null or bt.moon_id = p_moon_id
  order by m.display_order, bt.duration_ms, bt.achieved_at;
$$;

revoke all on function public.get_leaderboard(bigint) from public;
grant execute on function public.get_leaderboard(bigint) to anon, authenticated;
comment on function public.get_leaderboard(bigint) is
  'Clasificacion publica: solo nombre de luna, alias, tiempo y posicion.';

create or replace function public.delete_own_account()
returns void language plpgsql security definer set search_path = ''
as $$
declare
  caller_id uuid := auth.uid();
begin
  if caller_id is null then
    raise exception 'authentication required';
  end if;

  delete from auth.users where id = caller_id;
end;
$$;

revoke all on function public.delete_own_account() from public;
grant execute on function public.delete_own_account() to authenticated;
comment on function public.delete_own_account() is
  'Permite al usuario autenticado eliminar su propia cuenta y sus datos asociados.';

commit;
