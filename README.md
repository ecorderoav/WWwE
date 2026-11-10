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
Análisis completado (T3). En fase de diseño y primeras pantallas.

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

> De momento el juego solo muestra el menú principal. La conexión con Supabase (cuentas y clasificación) se añadirá en las próximas versiones.
