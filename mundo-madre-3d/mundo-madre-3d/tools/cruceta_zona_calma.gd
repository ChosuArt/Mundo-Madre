class_name CruzetaZonaCalma
extends Node3D
## Herramienta de depuración — SOLO capa de presentación (Principio 3):
## no calcula nada por su cuenta, solo dibuja lo que ya devuelve
## VientoObstaculoMath.calcular_zona_calma(). Vive en tools/ a
## propósito (ver tools_spawner.gd): si se borra esa carpeta entera,
## el juego sigue funcionando exactamente igual, sin ninguna
## referencia rota en ninguna escena.
##
## Se ubica en el CENTRO de la zona de calma (no en el obstáculo), y
## dibuja tres pares de brazos:
## - ancho (amarillo): perpendicular al viento, simétrico.
## - largo (celeste): a lo largo del eje del viento, simétrico
##   respecto al centro de la propia zona de calma.
## - alto (magenta): desde el suelo hacia arriba — ASIMÉTRICO a
##   propósito, porque una zona de calma no "flota": nace en la base
##   y sube, no sale del centro hacia ambos lados como los otros dos.

@export var obstaculo: ObstaculoViento
@export var viento: VientoRegional
@export var grosor_linea: float = 0.08

var _brazo_ancho_positivo: MeshInstance3D
var _brazo_ancho_negativo: MeshInstance3D
var _brazo_largo_positivo: MeshInstance3D
var _brazo_largo_negativo: MeshInstance3D
var _brazo_alto: MeshInstance3D

var _ultima_direccion: Vector3 = Vector3(0, 0, -1)


func _ready() -> void:
	_brazo_ancho_positivo = _crear_brazo(Color(0.95, 0.85, 0.2))
	_brazo_ancho_negativo = _crear_brazo(Color(0.95, 0.85, 0.2))
	_brazo_largo_positivo = _crear_brazo(Color(0.25, 0.85, 0.9))
	_brazo_largo_negativo = _crear_brazo(Color(0.25, 0.85, 0.9))
	_brazo_alto = _crear_brazo(Color(0.9, 0.25, 0.75))
	SimClock.tick.connect(_on_sim_tick)


func _crear_brazo(color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.8
	mesh_instance.material_override = material
	add_child(mesh_instance)
	return mesh_instance


func _on_sim_tick(_delta_sim_seconds: float) -> void:
	if obstaculo == null or viento == null:
		return

	if viento.direccion.length_squared() > 0.0001:
		_ultima_direccion = viento.direccion.normalized()

	var zona: Dictionary = VientoObstaculoMath.calcular_zona_calma(obstaculo.radio, obstaculo.altura, obstaculo.factor_largo_estela)
	var ancho: float = zona.ancho
	var largo: float = zona.largo
	var alto: float = zona.alto

	var lateral: Vector3 = _ultima_direccion.cross(Vector3.UP)
	if lateral.length_squared() <= 0.0001:
		lateral = Vector3.RIGHT
	lateral = lateral.normalized()

	# La cruceta entera se ubica en el centro de la zona de calma: el
	# borde del obstáculo (a favor del viento) más la mitad del largo.
	global_position = obstaculo.global_position + _ultima_direccion * (obstaculo.radio + largo * 0.5)

	_posicionar_brazo(_brazo_ancho_positivo, lateral, ancho)
	_posicionar_brazo(_brazo_ancho_negativo, -lateral, ancho)
	_posicionar_brazo(_brazo_largo_positivo, _ultima_direccion, largo * 0.5)
	_posicionar_brazo(_brazo_largo_negativo, -_ultima_direccion, largo * 0.5)
	_posicionar_brazo_altura(_brazo_alto, alto)


func _posicionar_brazo(mesh_instance: MeshInstance3D, direccion: Vector3, longitud: float) -> void:
	if longitud <= 0.001:
		mesh_instance.visible = false
		return
	mesh_instance.visible = true
	var box := BoxMesh.new()
	box.size = Vector3(grosor_linea, grosor_linea, longitud)
	mesh_instance.mesh = box
	mesh_instance.position = direccion * (longitud * 0.5)
	mesh_instance.look_at(mesh_instance.global_position + direccion, Vector3.UP)


func _posicionar_brazo_altura(mesh_instance: MeshInstance3D, altura_zona: float) -> void:
	if altura_zona <= 0.001:
		mesh_instance.visible = false
		return
	mesh_instance.visible = true
	var box := BoxMesh.new()
	box.size = Vector3(grosor_linea, altura_zona, grosor_linea)
	mesh_instance.mesh = box
	# Nace en el suelo (la cruceta ya está a nivel de suelo) y sube —
	# a propósito NO es simétrico como los otros dos brazos.
	mesh_instance.position = Vector3(0.0, altura_zona * 0.5, 0.0)
