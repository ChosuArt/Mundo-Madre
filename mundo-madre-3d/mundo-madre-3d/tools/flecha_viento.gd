class_name FlechaViento
extends Node3D
## Representación visual del viento — SOLO capa de presentación
## (Principio 3): lee el vector ya calculado por VientoRegional, nunca
## decide nada por su cuenta.
##
## Dibuja varias flechas alineadas sobre el eje de la dirección actual
## del viento, flotando a una altura fija, para que se vea la
## trayectoria completa cruzando el mapa (entrada → centro → salida),
## no un único punto fijo en el origen.

@export var viento: VientoRegional
@export var color: Color = Color(0.2, 0.5, 0.95)
@export var largo_base: float = 6.0
@export var altura_flotante: float = 3.0
@export var numero_flechas: int = 3
@export var espaciado_metros: float = 12.0

var _flechas: Array[Node3D] = []
var _ultima_direccion: Vector3 = Vector3(0, 0, -1)  # Norte, mientras no haya viento medido aún


func _ready() -> void:
	_build_visual()
	SimClock.tick.connect(_on_sim_tick)


func _build_visual() -> void:
	for i in range(numero_flechas):
		var flecha := _crear_flecha()
		add_child(flecha)
		_flechas.append(flecha)


func _crear_flecha() -> Node3D:
	var contenedor := Node3D.new()

	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.6

	var shaft := MeshInstance3D.new()
	var shaft_mesh := BoxMesh.new()
	shaft_mesh.size = Vector3(0.3, 0.3, largo_base)
	shaft.mesh = shaft_mesh
	shaft.material_override = material
	shaft.position = Vector3(0, 0, -largo_base * 0.5)
	contenedor.add_child(shaft)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.9, 0.5, 1.2)
	head.mesh = head_mesh
	head.material_override = material
	head.position = Vector3(0, 0, -largo_base - 0.6)
	contenedor.add_child(head)

	return contenedor


func _on_sim_tick(_delta_sim_seconds: float) -> void:
	if viento == null:
		return

	if viento.direccion.length_squared() > 0.0001:
		_ultima_direccion = viento.direccion.normalized()

	var factor: float = clamp(viento.velocidad / viento.velocidad_maxima, 0.05, 1.0)
	var mitad: float = float(numero_flechas - 1) * 0.5

	for i in range(numero_flechas):
		var flecha := _flechas[i]
		var offset: float = (float(i) - mitad) * espaciado_metros
		flecha.position = _ultima_direccion * offset + Vector3(0, altura_flotante, 0)
		flecha.look_at(flecha.global_position + _ultima_direccion, Vector3.UP)
		flecha.scale = Vector3.ONE * factor
