class_name FlechaViento
extends Node3D
## Representación visual del viento — SOLO capa de presentación
## (Principio 3): lee el vector ya calculado por VientoLocal, nunca
## decide nada por su cuenta. La geometría se arma una sola vez acá en
## código (no a mano en el editor) porque es una VISUALIZACIÓN de un
## dato que cambia todo el tiempo, no una pieza de escenografía fija
## como el terreno — es la misma categoría que el Label del HUD.

@export var viento: VientoRegional
@export var color: Color = Color(0.2, 0.5, 0.95)
@export var largo_base: float = 3.0


func _ready() -> void:
	_build_visual()
	SimClock.tick.connect(_on_sim_tick)


func _build_visual() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.6

	var shaft := MeshInstance3D.new()
	var shaft_mesh := BoxMesh.new()
	shaft_mesh.size = Vector3(0.15, 0.15, largo_base)
	shaft.mesh = shaft_mesh
	shaft.material_override = material
	shaft.position = Vector3(0, 0, -largo_base * 0.5)
	add_child(shaft)

	var head := MeshInstance3D.new()
	var head_mesh := BoxMesh.new()
	head_mesh.size = Vector3(0.5, 0.3, 0.6)
	head.mesh = head_mesh
	head.material_override = material
	head.position = Vector3(0, 0, -largo_base - 0.3)
	add_child(head)


func _on_sim_tick(_delta_sim_seconds: float) -> void:
	if viento.direccion.length_squared() > 0.0001:
		look_at(global_position + viento.direccion, Vector3.UP)

	var factor: float = clamp(viento.velocidad / viento.velocidad_maxima, 0.05, 1.0)
	scale = Vector3.ONE * factor
