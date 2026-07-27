extends CharacterBody3D
## Entidad PNJ — Etapa 0: patrulla entre puntos fijos con una
## máquina de estados simple (IDLE <-> PATROL).
##
## Los puntos de patrulla son hijos del propio PNJ (Marker3D), no
## referencias externas al mapa — la entidad es autosuficiente y se
## puede colocar en cualquier escena sin depender de nodos ajenos.
## Esto es deliberado: en la Etapa 10 esta misma entidad va a ganar
## una capa de voluntad propia sin que su base biológica/de movimiento
## tenga que rehacerse.

enum State { IDLE, PATROL }

@export_group("Movimiento")
@export var move_speed: float = 2.5
@export var idle_duration: float = 1.5
@export var arrival_distance: float = 0.2

@export_group("Cuerpo")
@export var capsule_radius: float = 0.35
@export var capsule_height: float = 1.6

const GRAVITY: float = 9.8

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	_build_body()

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
	material.albedo_color = Color(0.85, 0.35, 0.25)
	mesh_instance.material_override = material


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
