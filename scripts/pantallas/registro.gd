extends Control
## Pantalla de registro (CU-01 · RF-01 y RNF-04).

const ESCENA_INICIO_SESION := "res://scenes/ui/inicio_sesion.tscn"
const ESCENA_MENU := "res://scenes/ui/menu_principal.tscn"
const EDAD_MINIMA := 14  # RNF-04

@onready var campo_nombre: LineEdit = %NombreUsuario
@onready var campo_correo: LineEdit = %Correo
@onready var campo_contrasena: LineEdit = %Contrasena
@onready var campo_repetir: LineEdit = %RepetirContrasena
@onready var dia: SpinBox = %Dia
@onready var mes: SpinBox = %Mes
@onready var anio: SpinBox = %Anio
@onready var boton_registrar: Button = %Registrarse
@onready var boton_volver: Button = %Volver
@onready var mensaje: Label = %Mensaje


func _ready() -> void:
	campo_contrasena.secret = true
	campo_repetir.secret = true
	mensaje.text = ""
	# Límites de la fecha de nacimiento.
	dia.min_value = 1
	dia.max_value = 31
	mes.min_value = 1
	mes.max_value = 12
	anio.min_value = 1900
	anio.max_value = Time.get_date_dict_from_system().year
	boton_registrar.pressed.connect(_on_registrarse_pressed)
	boton_volver.pressed.connect(_on_volver_pressed)


func _on_registrarse_pressed() -> void:
	var nombre := campo_nombre.text.strip_edges()
	var correo := campo_correo.text.strip_edges()
	var contrasena := campo_contrasena.text
	var d := int(dia.value)
	var m := int(mes.value)
	var a := int(anio.value)

	# Paso 4 del CU-01: el juego comprueba que los datos son válidos.
	var error := _validar(nombre, correo, contrasena, campo_repetir.text, d, m, a)
	if error != "":
		mensaje.text = error
		return

	boton_registrar.disabled = true
	mensaje.text = "Creando la cuenta..."
	var fecha := "%04d-%02d-%02d" % [a, m, d]
	var r: Dictionary = await Supabase.registrar(correo, contrasena, nombre, fecha)
	boton_registrar.disabled = false

	if not r.ok:
		mensaje.text = r.error
	elif Supabase.ha_iniciado_sesion():
		get_tree().change_scene_to_file(ESCENA_MENU)
	else:
		# Pasa si en Supabase sigue activada la confirmación por correo.
		mensaje.text = "Cuenta creada. Revisa tu correo para confirmarla."


# Devuelve el texto del error, o "" si todo es correcto.
func _validar(nombre: String, correo: String, contrasena: String, repetir: String, d: int, m: int, a: int) -> String:
	var regex_nombre := RegEx.create_from_string("^[A-Za-z0-9_]{3,16}$")
	var regex_correo := RegEx.create_from_string("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
	if regex_nombre.search(nombre) == null:
		return "El nombre debe tener de 3 a 16 caracteres (letras, números o _)."
	if regex_correo.search(correo) == null:
		return "El correo no es válido."
	if contrasena.length() < 6:
		return "La contraseña debe tener al menos 6 caracteres."
	if contrasena != repetir:
		return "Las contraseñas no coinciden."
	if not _fecha_valida(d, m, a):
		return "La fecha de nacimiento no es válida."
	if _calcular_edad(d, m, a) < EDAD_MINIMA:
		return "Debes tener al menos %d años para registrarte." % EDAD_MINIMA
	return ""


func _fecha_valida(d: int, m: int, a: int) -> bool:
	var bisiesto := (a % 4 == 0 and a % 100 != 0) or a % 400 == 0
	var dias_mes := [31, 29 if bisiesto else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	return d <= dias_mes[m - 1]


func _calcular_edad(d: int, m: int, a: int) -> int:
	var hoy := Time.get_date_dict_from_system()
	var edad: int = hoy.year - a
	# Si este año aún no ha cumplido, se resta uno.
	if hoy.month < m or (hoy.month == m and hoy.day < d):
		edad -= 1
	return edad


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_INICIO_SESION)
