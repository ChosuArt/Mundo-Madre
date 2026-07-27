extends CharacterBody3D
## Entidad jugable — Etapa 0: esqueleto jugable.
##
## Se mueve sobre una escena mínima. La cámara es fija al personaje,
## en ángulo isométrico (referencia visual: Baldur's Gate 3 / The Sims),
## sin control de rotación por parte del jugador en esta etapa — eso
## queda abierto para una etapa futura si se decide agregarlo.
##
## Principio 1 del documento de visión: la forma de colisión y la malla
## visual se derivan de los mismos parámetros exportados, nunca de dos
## números separados que alguien deba mantener sincronizados.

@export_group("Cuerpo")
@export var move_speed: float = 5.0
@export var capsule_radius: float = 0.4
@export var capsule_height: float = 1.8

@export_group("Cámara")
@export var camera_yaw_degrees: float = 45.0
@export var camera_pitch_degrees: float = -40.0
@export var camera_distance: float = 12.0

const GRAVITY: float = 9.8

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D


func _ready() -> void:
	_build_body()
	_build_camera()


func _build_body() -> void:
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = capsule_radius
	capsule_shape.height = capsule_height
	collision_shape.shape = capsule_shape

	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = capsule_radius
	capsule_mesh.height = capsule_height
	mesh_instance.mesh = capsule_mesh

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.25, 0.55, 0.95)
	mesh_instance.material_override = material


func _build_camera() -> void:
	# Cámara fija al jugador: es hija directa del personaje, con un
	# ángulo constante. A diferencia de BG3 o The Sims, en esta etapa
	# no se puede rotar ni desplazar de forma independiente.
	camera_pivot.rotation_degrees = Vector3(camera_pitch_degrees, camera_yaw_degrees, 0.0)
	camera.position = Vector3(0.0, 0.0, camera_distance)
	camera.current = true


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var direction := _get_movement_direction()
	if direction.length_squared() > 0.0:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		mesh_instance.look_at(mesh_instance.global_position + direction, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	move_and_slide()


func _get_movement_direction() -> Vector3:
	# El movimiento se traduce a los ejes de la cámara isométrica fija,
	# para que W/A/S/D se sientan alineados con lo que se ve en pantalla,
	# sin importar hacia dónde "mire" el mundo en términos absolutos.
	var forward_input := float(Input.is_key_pressed(KEY_W)) - float(Input.is_key_pressed(KEY_S))
	var right_input := float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))

	var input_vector := Vector2(right_input, forward_input)
	if input_vector.length_squared() == 0.0:
		return Vector3.ZERO
	input_vector = input_vector.normalized()

	var cam_basis := camera_pivot.global_transform.basis
	var forward := -cam_basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var right := cam_basis.x
	right.y = 0.0
	right = right.normalized()

	return (forward * input_vector.y + right * input_vector.x).normalized()
