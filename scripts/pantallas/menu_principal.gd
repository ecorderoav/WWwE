extends Control
## Menú principal (RF-06), según el boceto del prototipo:
## Jugar, Clasificación, Perfil y configuración, y Salir.

const ESCENA_INICIO_SESION := "res://scenes/ui/inicio_sesion.tscn"

@onready var saludo: Label = %Saludo
@onready var mensaje: Label = %Mensaje


func _ready() -> void:
	# Si alguien llega aquí sin sesión, vuelve al inicio de sesión.
	if not Supabase.ha_iniciado_sesion():
		get_tree().call_deferred("change_scene_to_file", ESCENA_INICIO_SESION)
		return

	saludo.text = "Hola, %s" % Supabase.nombre_usuario
	mensaje.text = ""
	# De momento estas opciones aún no tienen pantalla.
	%Jugar.pressed.connect(_pendiente)
	%Clasificacion.pressed.connect(_pendiente)
	%PerfilConfiguracion.pressed.connect(_pendiente)
	%Salir.pressed.connect(func(): get_tree().quit())


func _pendiente() -> void:
	mensaje.text = "Disponible próximamente."
