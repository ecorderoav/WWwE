extends Control
## Pantalla de inicio de sesión (RF-02). Es la primera escena del juego.

# Cambia las rutas si tus escenas están en otra carpeta.
const ESCENA_REGISTRO := "res://scenes/ui/registro.tscn"
const ESCENA_MENU := "res://scenes/ui/menu_principal.tscn"

# El símbolo % busca el nodo por su nombre único (clic derecho > "Access as Unique Name").
@onready var campo_correo: LineEdit = %Correo
@onready var campo_contrasena: LineEdit = %Contrasena
@onready var boton_entrar: Button = %Entrar
@onready var boton_crear_cuenta: Button = %CrearCuenta
@onready var mensaje: Label = %Mensaje


func _ready() -> void:
	campo_contrasena.secret = true
	mensaje.text = ""
	boton_entrar.pressed.connect(_on_entrar_pressed)
	boton_crear_cuenta.pressed.connect(_on_crear_cuenta_pressed)
	# Pulsar Intro en la contraseña también inicia sesión.
	campo_contrasena.text_submitted.connect(func(_t): _on_entrar_pressed())


func _on_entrar_pressed() -> void:
	var correo := campo_correo.text.strip_edges()
	var contrasena := campo_contrasena.text
	if correo == "" or contrasena == "":
		mensaje.text = "Rellena el correo y la contraseña."
		return

	boton_entrar.disabled = true
	mensaje.text = "Conectando..."
	var r: Dictionary = await Supabase.iniciar_sesion(correo, contrasena)
	boton_entrar.disabled = false

	if r.ok:
		get_tree().change_scene_to_file(ESCENA_MENU)
	else:
		mensaje.text = r.error


func _on_crear_cuenta_pressed() -> void:
	get_tree().change_scene_to_file(ESCENA_REGISTRO)
