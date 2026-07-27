class_name CamaraLibre
extends Camera3D
## Cámara de exploración provisional, independiente del jugador o el
## PNJ — solo para recorrer el terreno mientras se ajusta el sistema
## causal. No representa ninguna entidad del mundo ni afecta la
## simulación; es pura herramienta de desarrollo.

@export var velocidad_movimiento: float = 10.0
@export var velocidad_vertical: float = 8.0
@export var sensibilidad_mouse: float = 0.15
@export var pitch_maximo_grados: float = 89.0

var _yaw_degrees: float = 0.0
var _pitch_degrees: float = 0.0


func _ready() -> void:
	current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_yaw_degrees = rotation_degrees.y
	_pitch_degrees = rotation_degrees.x


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw_degrees -= event.relative.x * sensibilidad_mouse
		_pitch_degrees -= event.relative.y * sensibilidad_mouse
		_pitch_degrees = clamp(_pitch_degrees, -pitch_maximo_grados, pitch_maximo_grados)
		rotation_degrees = Vector3(_pitch_degrees, _yaw_degrees, 0.0)

	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized() if forward.length_squared() > 0.0001 else Vector3.ZERO

	var right: Vector3 = global_transform.basis.x
	right.y = 0.0
	right = right.normalized() if right.length_squared() > 0.0001 else Vector3.ZERO

	var movimiento_horizontal := Vector3.ZERO
	movimiento_horizontal += forward * (float(Input.is_key_pressed(KEY_W)) - float(Input.is_key_pressed(KEY_S)))
	movimiento_horizontal += right * (float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A)))
	if movimiento_horizontal.length_squared() > 0.0001:
		movimiento_horizontal = movimiento_horizontal.normalized()

	var movimiento_vertical: float = float(Input.is_key_pressed(KEY_R)) - float(Input.is_key_pressed(KEY_F))

	global_position += movimiento_horizontal * velocidad_movimiento * delta
	global_position += Vector3.UP * movimiento_vertical * velocidad_vertical * delta
