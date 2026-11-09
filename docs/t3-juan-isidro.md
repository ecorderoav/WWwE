# T3 · Aportación de Juan Isidro Caballero Díaz

## 1. Requisitos técnicos

| ID | Descripción | Prioridad |
|---|---|---|
| RT-01 | El juego se desarrollará con Godot 4 y usaremos GDScript para programar su funcionamiento. | Alta |
| RT-02 | Usaremos Supabase para gestionar las cuentas, los perfiles, el progreso de las partidas y los mejores tiempos. | Alta |
| RT-03 | Hará falta conexión a internet para registrarse, iniciar sesión, sincronizar el progreso y consultar o actualizar la clasificación. Si no hay conexión, el juego mostrará un aviso. | Alta |
| RT-04 | El juego tendrá que poder exportarse y funcionar en ordenadores con Windows y Linux. | Alta |
| RT-05 | La base de datos tendrá tablas separadas para los perfiles, el progreso y los mejores tiempos. Los cambios en su estructura se guardarán en archivos de migración. | Media |
| RT-06 | En el juego solo se incluirá la clave pública necesaria para conectarse a Supabase. Las claves administrativas no se guardarán en el proyecto ni se subirán al repositorio. | Alta |

## 2. Requisitos no funcionales de seguridad y datos

| ID | Descripción | Prioridad |
|---|---|---|
| RNF-01 | Supabase Auth se encargará de las contraseñas. El juego no las guardará en texto plano ni podrá consultarlas. | Alta |
| RNF-02 | Cada jugador solo podrá ver y modificar su propio perfil y su progreso. Para ello se configurarán permisos en la base de datos. | Alta |
| RNF-03 | En la clasificación solo aparecerán el nombre de usuario, la posición y el tiempo. El correo y el resto de los datos personales no serán públicos. | Alta |
| RNF-04 | El registro estará pensado para usuarios a partir de 14 años. Los menores de 14 necesitarán el consentimiento de su padre, madre o tutor legal. | Alta |

## 3. Casos de uso

### CU-01 · Registrarse

**Actor:** visitante.

**Precondiciones:**

- El usuario no tiene una sesión iniciada.
- El dispositivo dispone de conexión a internet.

**Flujo principal:**

1. El visitante selecciona la opción «Registrarse».
2. El juego pide un correo electrónico, una contraseña, un nombre de usuario y la confirmación de edad.
3. El visitante rellena los datos y pulsa el botón para continuar.
4. El juego comprueba que los datos son válidos.
5. Supabase crea la cuenta y el perfil asociado.
6. El juego confirma el registro y muestra el menú principal.

**Flujos alternativos:**

- Si falta algún dato o su formato no es válido, el juego indica qué campo hay que corregir.
- Si el correo o el nombre de usuario ya están registrados, se informa al visitante y se le pide que utilice otro.
- Si el usuario indica que es menor de 14 años y no dispone del consentimiento de su tutor legal, no se completa el registro.
- Si falla la conexión, se conserva el formulario y se ofrece la posibilidad de volver a intentarlo.

### CU-02 · Eliminar cuenta

**Actor:** jugador autenticado.

**Precondiciones:**

- El jugador tiene una sesión iniciada.
- La cuenta existe y el dispositivo dispone de conexión a internet.

**Flujo principal:**

1. El jugador entra en su perfil y selecciona «Eliminar cuenta».
2. El juego avisa de que se eliminarán la cuenta, el perfil, el progreso y los tiempos guardados.
3. El jugador confirma que desea continuar.
4. El juego vuelve a comprobar la identidad del jugador.
5. Se eliminan los datos asociados al usuario y después su cuenta de acceso.
6. El juego cierra la sesión y vuelve a la pantalla inicial.

**Flujos alternativos:**

- Si el jugador cancela la confirmación, no se modifica ningún dato y vuelve a su perfil.
- Si la comprobación de identidad falla, la cuenta no se elimina y se solicita que vuelva a iniciar sesión.
- Si se produce un error de conexión o del servidor, no se da la operación por terminada y se informa al jugador para que lo intente más tarde.

## Fuentes consultadas

- Documentación oficial de Godot 4: requisitos del sistema.
- Documentación oficial de Supabase: Auth, seguridad de contraseñas y políticas RLS.
- Ley Orgánica 3/2018, artículo 7, sobre el consentimiento de menores de edad.
