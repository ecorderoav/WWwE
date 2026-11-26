# What's Wrong with Earth?

Videojuego de plataformas 2D en pixel art con historia y clasificación en línea.
Proyecto final del módulo de Proyecto del CFGS Desarrollo de Aplicaciones Multiplataforma (CEAC FP, curso 2026-2027).

## Descripción
Tras la caída repentina de la Tierra, un astronauta escapa a la estación abandonada de la Luna
y descubre una vida que la humanidad desconocía… y una segunda luna. El jugador supera enemigos
y obstáculos saltando y compite por el mejor tiempo en una clasificación en línea por luna.

## Equipo · Grupo 04
- Erik Cordero Avilés: coordinación, diseño de niveles y documentación
- Juan Isidro Caballero Díaz: base de datos
- Jordi Muñoz Sánchez: pruebas

## Tecnologías
- Godot 4 y GDScript
- Supabase (PostgreSQL, autenticación y API REST)
- Git, GitHub y GitHub Projects

## Estado
Diseño completado (T4). Ya funcionan el registro, el inicio de sesión y el menú principal conectados a Supabase.

## Instalación y ejecución

### Requisitos
- [Godot Engine 4.4](https://godotengine.org/download) (versión estándar, no la .NET)
- Git o GitHub Desktop para clonar el repositorio

### Pasos
1. Clona el repositorio:
   ```bash
   git clone https://github.com/ecorderoav/WWwE.git
   ```
   O con GitHub Desktop: *File → Clone repository*.
2. Abre Godot 4.4 y, en el gestor de proyectos, pulsa **Importar**.
3. Selecciona el archivo `project.godot` de la carpeta clonada y pulsa **Importar y editar**.
4. Pulsa **F5** (o el botón ▶) para ejecutar el juego.

## Estado de la implementación (T4 · 26/11/2026)

| Funcionalidad | Estado |
|---|---|
| Base de datos en Supabase: tablas, RLS y funciones (`supabase/migrations/`) | ✅ Hecho |
| Conexión del juego con Supabase (`scripts/autoload/supabase.gd`) | ✅ Hecho |
| Registro con validación y edad mínima de 14 años | ✅ Hecho |
| Inicio de sesión | ✅ Hecho |
| Menú principal | 🟡 En parte: las opciones aún no abren su pantalla |
| Niveles, enemigos, cronómetro, historia y progreso | ⏳ Pendiente (T5) |
| Clasificación, perfil y configuración | ⏳ Pendiente (T5) |

### Cómo probarlo
1. Ejecuta el juego con F5: la primera pantalla es el inicio de sesión.
2. Crea una cuenta desde «Regístrate» (hace falta tener al menos 14 años).
3. Al registrarte entras en el menú principal y el jugador aparece en la tabla `players` de Supabase.

## Estructura del repositorio
- `assets/`: recursos gráficos y de sonido.
- `scenes/`: escenas de Godot (`characters/`, `levels/`, `menu/` y `ui/`).
- `scripts/`: código en GDScript; `autoload/` tiene la conexión con Supabase y `pantallas/`, los scripts de cada pantalla.
- `supabase/migrations/`: SQL con las tablas, las políticas RLS y las funciones de la base de datos.
- `docs/`: aportaciones de cada integrante a la memoria.
