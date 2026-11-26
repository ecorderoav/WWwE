extends Node
## Servicio de conexión con Supabase (Auth y, más adelante, la API REST de las tablas).
## Se registra como Autoload con el nombre "Supabase", así cualquier escena puede
## llamar a Supabase.iniciar_sesion(...) sin tener que crear nada.

# Datos del proyecto (Project Settings > API Keys en Supabase).
# Solo va la clave PÚBLICA (publishable). La secreta no se pone nunca aquí (RT-06).
const URL := "https://xdzgyutxpdydamxtyqkg.supabase.co"
const CLAVE_PUBLICA := "sb_publishable_bxgNOhsasATAXw4EBoI0nw_ygUtSxMO"

# Sesión del jugador mientras el juego está abierto.
var access_token := ""
var usuario_id := ""
var correo := ""
var nombre_usuario := ""


func ha_iniciado_sesion() -> bool:
	return access_token != ""


## RF-01 · Crear cuenta. El nombre y la fecha de nacimiento viajan en "data"
## (metadatos del usuario) para que la base de datos pueda crear el perfil.
func registrar(email: String, password: String, nombre: String, fecha_nacimiento: String) -> Dictionary:
	var cuerpo := {
		"email": email,
		"password": password,
		"data": {"nombre_usuario": nombre, "fecha_nacimiento": fecha_nacimiento},
	}
	var r: Dictionary = await _peticion("/auth/v1/signup", HTTPClient.METHOD_POST, cuerpo)
	if r.ok:
		_guardar_sesion(r.datos)
	elif r.codigo == 500:
		# El trigger de la base de datos rechaza el perfil (nombre repetido o menor de 14 años).
		r.error = "No se ha podido crear la cuenta: el nombre de usuario ya existe o la fecha no es válida."
	return r


## RF-02 · Iniciar sesión con correo y contraseña.
func iniciar_sesion(email: String, password: String) -> Dictionary:
	var cuerpo := {"email": email, "password": password}
	var r: Dictionary = await _peticion("/auth/v1/token?grant_type=password", HTTPClient.METHOD_POST, cuerpo)
	if r.ok:
		_guardar_sesion(r.datos)
	return r


func cerrar_sesion() -> void:
	if ha_iniciado_sesion():
		await _peticion("/auth/v1/logout", HTTPClient.METHOD_POST, {})
	access_token = ""
	usuario_id = ""
	correo = ""
	nombre_usuario = ""


# Guarda el token y los datos del usuario que devuelve Supabase.
# Si la confirmación por correo está activada, el registro no devuelve token.
func _guardar_sesion(datos) -> void:
	if not (datos is Dictionary):
		return
	access_token = str(datos.get("access_token", ""))
	var usuario: Dictionary = datos.get("user", {})
	usuario_id = str(usuario.get("id", ""))
	correo = str(usuario.get("email", ""))
	var metadatos: Dictionary = usuario.get("user_metadata", {})
	nombre_usuario = str(metadatos.get("nombre_usuario", ""))


## Envía una petición HTTP a Supabase y devuelve siempre un diccionario:
## { ok: bool, codigo: int, datos: Variant, error: String }
func _peticion(ruta: String, metodo: int, cuerpo = null) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)

	# La clave pública va siempre en "apikey". El token del jugador, solo si ha iniciado sesión.
	var cabeceras := PackedStringArray(["apikey: " + CLAVE_PUBLICA, "Content-Type: application/json"])
	if access_token != "":
		cabeceras.append("Authorization: Bearer " + access_token)

	var texto := "" if cuerpo == null else JSON.stringify(cuerpo)
	if http.request(URL + ruta, cabeceras, metodo, texto) != OK:
		http.queue_free()
		return {"ok": false, "codigo": 0, "datos": null, "error": "No se ha podido enviar la petición."}

	# Espera a la respuesta: [resultado, código HTTP, cabeceras, cuerpo]
	var respuesta: Array = await http.request_completed
	http.queue_free()

	var resultado: int = respuesta[0]
	var codigo: int = respuesta[1]
	var cuerpo_texto: String = respuesta[3].get_string_from_utf8()
	var datos = null if cuerpo_texto == "" else JSON.parse_string(cuerpo_texto)

	# RT-03 · Sin conexión: se avisa al jugador.
	if resultado != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "codigo": 0, "datos": null, "error": "Sin conexión. Comprueba tu conexión a internet."}
	if codigo >= 200 and codigo < 300:
		return {"ok": true, "codigo": codigo, "datos": datos, "error": ""}
	return {"ok": false, "codigo": codigo, "datos": datos, "error": _traducir_error(datos)}


# Convierte los códigos de error de Supabase en mensajes para el jugador.
func _traducir_error(datos) -> String:
	var clave := ""
	if datos is Dictionary:
		clave = str(datos.get("error_code", datos.get("error", "")))
	match clave:
		"invalid_credentials", "invalid_grant":
			return "Correo o contraseña incorrectos."
		"user_already_exists", "email_exists":
			return "Ya existe una cuenta con ese correo."
		"weak_password":
			return "La contraseña es demasiado débil."
		"email_address_invalid", "validation_failed":
			return "El correo no es válido."
		"email_not_confirmed":
			return "Falta confirmar el correo."
		"over_request_rate_limit", "over_email_send_rate_limit":
			return "Demasiados intentos. Espera un momento."
		_:
			return "Ha ocurrido un error. Inténtalo de nuevo."
