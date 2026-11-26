# T4 - Diseño: coordinación, implementación y textos

*Autor:* Erik Cordero Avilés  
*Grupo:* G04  
*Proyecto:* What's Wrong with Earth?

## Tareas realizadas
- Reparto de las tareas de la T4 y tarjetas del milestone T4 en el tablero.
- Creación del proyecto de Supabase, configuración de la autenticación e invitación al equipo.
- Montaje en Godot de las escenas de inicio de sesión, registro y menú principal (`scenes/ui/`), configuración del autoload `Supabase` y de la escena principal.
- Prueba del registro y del inicio de sesión con la base de datos: el jugador se crea en la tabla `players`.
- Revisión del modelo de datos de Juan Isidro y de los bocetos de Jordi.
- Redacción de los textos del apartado 4.2 y del estado de la implementación, y montaje de la memoria.

Los scripts de `scripts/` y los diagramas de arquitectura, clases, secuencia y navegación se han hecho con apoyo de IA, tal como se declara en el Anexo C de la memoria.

## Textos del apartado 4.2

### 4.2. Diseño
En este apartado se presenta el diseño del juego, que parte de los requisitos y de los casos de uso del análisis. En primer lugar se explican la arquitectura de la aplicación y el diagrama de clases. Seguidamente se describe el modelo de datos y se muestran los diagramas de secuencia de dos casos de uso principales. Por último, se incluye el prototipo de la interfaz con el mapa de navegación.

### 4.2.1. Arquitectura de la aplicación# T4 - Diseño: coordinación, implementación y textos

*Autor:* Erik Cordero Avilés  
*Grupo:* G04  
*Proyecto:* What's Wrong with Earth?

## Tareas realizadas
- Reparto de las tareas de la T4 y tarjetas del milestone T4 en el tablero.
- Creación del proyecto de Supabase, configuración de la autenticación e invitación al equipo.
- Montaje en Godot de las escenas de inicio de sesión, registro y menú principal (`scenes/ui/`), configuración del autoload `Supabase` y de la escena principal.
- Prueba del registro y del inicio de sesión con la base de datos: el jugador se crea en la tabla `players`.
- Revisión del modelo de datos de Juan Isidro y de los bocetos de Jordi.
- Redacción de los textos del apartado 4.2 y del estado de la implementación, y montaje de la memoria.

Los scripts de `scripts/` y los diagramas de arquitectura, clases, secuencia y navegación se han hecho con apoyo de IA, tal como se declara en el Anexo C de la memoria.

## Textos del apartado 4.2

### 4.2. Diseño
En este apartado se presenta el diseño del juego, que parte de los requisitos y de los casos de uso del análisis. En primer lugar se explican la arquitectura de la aplicación y el diagrama de clases. Seguidamente se describe el modelo de datos y se muestran los diagramas de secuencia de dos casos de uso principales. Por último, se incluye el prototipo de la interfaz con el mapa de navegación.

### 4.2.1. Arquitectura de la aplicación
El juego sigue una arquitectura cliente-servidor, como se puede ver en la Figura 3. El cliente es el propio juego, programado y diseñado en Godot, y el servidor es Supabase, que gestiona las cuentas y la base de datos. Dentro del juego, el código se organiza en tres capas: la de presentación, formada por las escenas que ve el jugador; la de lógica, con los scripts que controlan el juego y el gestor de la partida; y la de acceso a datos, que es la única que se comunica con Supabase. La comunicación se hace mediante peticiones HTTPS en formato JSON, y el juego solo incluye la clave pública del proyecto y el token de sesión del jugador (RT-06).

### 4.2.2. Diagrama de clases
La Figura 4 muestra el diagrama de clases del juego. En Godot, cada script hereda del tipo de nodo al que se asocia: por eso las pantallas heredan de Control, el nivel de Node2D, y el jugador y los enemigos de CharacterBody2D, el nodo pensado para personajes con físicas. Las clases Supabase y GestorPartida son autoloads, es decir, Godot las carga automáticamente al iniciarse el juego. Supabase reúne todas las peticiones al servidor, mientras que GestorPartida guarda el progreso, la configuración y los tiempos del jugador durante la partida.

### 4.2.3. Modelo de datos
El modelo de datos se ha diseñado a partir de los datos que guarda el juego, recogidos en la Tabla 1. La Figura 5 muestra el diagrama entidad-relación y la Tabla 9, el modelo relacional, con las columnas, los tipos de datos y las claves de cada tabla.

### 4.2.4. Diagramas de secuencia
Se han elegido dos casos de uso principales: Registrarse (CU-01), dado que es la entrada al juego, y Jugar un nivel (CU-03), porque es su función principal. La Figura 6 muestra cómo el juego comprueba primero los datos del formulario y, si son válidos, los envía a Supabase Auth, que crea la cuenta mientras la base de datos crea el perfil del jugador. La Figura 7 muestra cómo se carga el progreso al pulsar «Jugar», cómo el cronómetro mide el nivel y cómo, al terminarlo, se guarda el progreso y se envía el tiempo, que solo se conserva si mejora la marca anterior. En los dos diagramas aparecen también los casos de error, como los datos no válidos o la falta de conexión.

### 4.2.5. Prototipo de la interfaz y mapa de navegación
Se han dibujado a mano los bocetos de las pantallas (Figuras 9 y 10) a partir de los requisitos funcionales y de los casos de uso. Respecto al boceto, en el inicio de sesión el campo «Usuario» se ha cambiado por «Correo», ya que Supabase Auth identifica a los jugadores por su correo electrónico. La Figura 8 muestra el mapa de navegación, es decir, cómo se pasa de una pantalla a otra desde el inicio de sesión hasta el juego.

### 4.3. Implementación (estado actual)
Aunque la implementación se completará en la entrega final, el proyecto en el repositorio ya refleja un avance real del desarrollo. Funcionan tanto la conexión del juego con Supabase como el registro con la comprobación de la edad mínima, además del inicio de sesión y el menú principal (Figura 11). La base de datos tiene creadas sus tablas con las políticas de seguridad correspondientes (Figura 12). La Tabla 10 recoge qué está implementado y qué queda pendiente para la entrega final.

El juego sigue una arquitectura cliente-servidor, como se puede ver en la Figura 3. El cliente es el propio juego, programado y diseñado en Godot, y el servidor es Supabase, que gestiona las cuentas y la base de datos. Dentro del juego, el código se organiza en tres capas: la de presentación, formada por las escenas que ve el jugador; la de lógica, con los scripts que controlan el juego y el gestor de la partida; y la de acceso a datos, que es la única que se comunica con Supabase. La comunicación se hace mediante peticiones HTTPS en formato JSON, y el juego solo incluye la clave pública del proyecto y el token de sesión del jugador (RT-06).

### 4.2.2. Diagrama de clases
La Figura 4 muestra el diagrama de clases del juego. En Godot, cada script hereda del tipo de nodo al que se asocia: por eso las pantallas heredan de Control, el nivel de Node2D, y el jugador y los enemigos de CharacterBody2D, el nodo pensado para personajes con físicas. Las clases Supabase y GestorPartida son autoloads, es decir, Godot las carga automáticamente al iniciarse el juego. Supabase reúne todas las peticiones al servidor, mientras que GestorPartida guarda el progreso, la configuración y los tiempos del jugador durante la partida.

### 4.2.3. Modelo de datos
El modelo de datos se ha diseñado a partir de los datos que guarda el juego, recogidos en la Tabla 1. La Figura 5 muestra el diagrama entidad-relación y la Tabla 9, el modelo relacional, con las columnas, los tipos de datos y las claves de cada tabla.

### 4.2.4. Diagramas de secuencia
Se han elegido dos casos de uso principales: Registrarse (CU-01), dado que es la entrada al juego, y Jugar un nivel (CU-03), porque es su función principal. La Figura 6 muestra cómo el juego comprueba primero los datos del formulario y, si son válidos, los envía a Supabase Auth, que crea la cuenta mientras la base de datos crea el perfil del jugador. La Figura 7 muestra cómo se carga el progreso al pulsar «Jugar», cómo el cronómetro mide el nivel y cómo, al terminarlo, se guarda el progreso y se envía el tiempo, que solo se conserva si mejora la marca anterior. En los dos diagramas aparecen también los casos de error, como los datos no válidos o la falta de conexión.

### 4.2.5. Prototipo de la interfaz y mapa de navegación
Se han dibujado a mano los bocetos de las pantallas (Figuras 9 y 10) a partir de los requisitos funcionales y de los casos de uso. Respecto al boceto, en el inicio de sesión el campo «Usuario» se ha cambiado por «Correo», ya que Supabase Auth identifica a los jugadores por su correo electrónico. La Figura 8 muestra el mapa de navegación, es decir, cómo se pasa de una pantalla a otra desde el inicio de sesión hasta el juego.

### 4.3. Implementación (estado actual)
Aunque la implementación se completará en la entrega final, el proyecto en el repositorio ya refleja un avance real del desarrollo. Funcionan tanto la conexión del juego con Supabase como el registro con la comprobación de la edad mínima, además del inicio de sesión y el menú principal (Figura 11). La base de datos tiene creadas sus tablas con las políticas de seguridad correspondientes (Figura 12). La Tabla 10 recoge qué está implementado y qué queda pendiente para la entrega final.
