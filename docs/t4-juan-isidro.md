# T4 - Modelo de datos y persistencia

**Autor:** Juan Isidro Caballero Díaz  
**Grupo:** G04  
**Proyecto:** What's Wrong with Earth?

## Explicación del modelo

Hemos separado la cuenta de Supabase Auth de los datos propios del juego. Auth se encarga del correo, la contraseña y la sesión, mientras que la tabla `players` guarda el nombre que se muestra en el juego y la fecha de nacimiento. Al registrarse, el juego envía `nombre_usuario` y `fecha_nacimiento` dentro de los metadatos y un trigger crea automáticamente el perfil y la configuración inicial. La fecha se valida para impedir registros de menores de 14 años y la contraseña no se copia en ninguna tabla pública.

Cada jugador tiene una configuración y puede tener un registro de progreso por nivel y una mejor marca por luna. Las lunas y los niveles son tablas independientes, por lo que se pueden añadir niveles sin cambiar la estructura del jugador. Las políticas RLS permiten que cada usuario lea y modifique solamente sus datos. La clasificación se consulta mediante `get_leaderboard`, que es pública pero devuelve únicamente el nombre de la luna, el alias, el tiempo y la posición.

## Diagrama entidad relación

```mermaid
erDiagram
    AUTH_USERS ||--|| PLAYERS : identifica
    PLAYERS ||--|| PLAYER_SETTINGS : configura
    PLAYERS ||--o{ PLAYER_PROGRESS : guarda
    LEVELS ||--o{ PLAYER_PROGRESS : registra
    MOONS ||--|{ LEVELS : contiene
    PLAYERS ||--o{ BEST_TIMES : consigue
    MOONS ||--o{ BEST_TIMES : clasifica

    AUTH_USERS {
        uuid id PK
        text email
        text password_gestionada_por_Auth
    }
    PLAYERS {
        uuid user_id PK_FK
        text username UK
        date date_of_birth
        timestamptz created_at
        timestamptz updated_at
    }
    PLAYER_SETTINGS {
        uuid user_id PK_FK
        smallint master_volume
        smallint music_volume
        smallint effects_volume
        jsonb controls
        timestamptz updated_at
    }
    MOONS {
        bigint id PK
        text code UK
        text name UK
        smallint display_order UK
    }
    LEVELS {
        bigint id PK
        bigint moon_id FK
        smallint level_number
        text name
    }
    PLAYER_PROGRESS {
        uuid user_id PK_FK
        bigint level_id PK_FK
        boolean unlocked
        boolean completed
        timestamptz completed_at
        timestamptz updated_at
    }
    BEST_TIMES {
        bigint id PK
        uuid user_id FK
        bigint moon_id FK
        bigint duration_ms
        timestamptz achieved_at
    }
```

Cardinalidades principales:

- Un usuario de Auth corresponde a un jugador.
- Un jugador tiene una configuración.
- Una luna contiene uno o varios niveles.
- Un jugador puede tener progreso en varios niveles.
- Un nivel puede tener progreso de varios jugadores.
- Un jugador puede tener una mejor marca por cada luna.

## Modelo relacional

### players

| Columna | Tipo | Clave o restricción |
|---|---|---|
| `user_id` | `uuid` | PK y FK a `auth.users.id`, borrado en cascada |
| `username` | `text` | Obligatorio y único sin distinguir mayúsculas |
| `date_of_birth` | `date` | Obligatoria; el trigger exige una edad mínima de 14 años |
| `created_at` | `timestamptz` | Obligatoria, valor automático |
| `updated_at` | `timestamptz` | Obligatoria, valor automático |

### player_settings

| Columna | Tipo | Clave o restricción |
|---|---|---|
| `user_id` | `uuid` | PK y FK a `players.user_id`, borrado en cascada |
| `master_volume` | `smallint` | Entre 0 y 100 |
| `music_volume` | `smallint` | Entre 0 y 100 |
| `effects_volume` | `smallint` | Entre 0 y 100 |
| `controls` | `jsonb` | Objeto JSON |
| `updated_at` | `timestamptz` | Obligatoria, valor automático |

### moons

| Columna | Tipo | Clave o restricción |
|---|---|---|
| `id` | `bigint` | PK generada automáticamente |
| `code` | `text` | Obligatorio y único |
| `name` | `text` | Obligatorio y único |
| `display_order` | `smallint` | Obligatorio, único y mayor que 0 |

### levels

| Columna | Tipo | Clave o restricción |
|---|---|---|
| `id` | `bigint` | PK generada automáticamente |
| `moon_id` | `bigint` | FK a `moons.id` |
| `level_number` | `smallint` | Obligatorio y mayor que 0 |
| `name` | `text` | Obligatorio |

La combinación `moon_id + level_number` es única.

### player_progress

| Columna | Tipo | Clave o restricción |
|---|---|---|
| `user_id` | `uuid` | PK compuesta y FK a `players.user_id` |
| `level_id` | `bigint` | PK compuesta y FK a `levels.id` |
| `unlocked` | `boolean` | Obligatorio |
| `completed` | `boolean` | Obligatorio; requiere el nivel desbloqueado |
| `completed_at` | `timestamptz` | Admite nulo |
| `updated_at` | `timestamptz` | Obligatoria, valor automático |

### best_times

| Columna | Tipo | Clave o restricción |
|---|---|---|
| `id` | `bigint` | PK generada automáticamente |
| `user_id` | `uuid` | FK a `players.user_id`, borrado en cascada |
| `moon_id` | `bigint` | FK a `moons.id` |
| `duration_ms` | `bigint` | Obligatorio y mayor que 0 |
| `achieved_at` | `timestamptz` | Obligatoria, valor automático |

La combinación `user_id + moon_id` es única, de forma que cada jugador conserva una sola mejor marca por luna.

## Seguridad y estado

- RLS está activado en todas las tablas.
- `players`, `player_settings`, `player_progress` y `best_times` solo permiten el acceso del propietario.
- `moons` y `levels` son datos de consulta pública.
- `submit_best_time` comprueba el usuario autenticado y conserva el tiempo menor.
- `get_leaderboard` puede ejecutarse sin iniciar sesión, pero solo devuelve luna, alias, tiempo y posición.
- `delete_own_account` permite que cada jugador elimine su propia cuenta y activa el borrado en cascada de sus datos.
- El archivo SQL se ejecutó y verificó en el proyecto de Supabase del grupo el 25/11/2026.
