class_name ObstaculoViento
extends StaticBody3D
## Un obstáculo sólido en el mapa (roca, tronco, o lo que sea — la
## forma exacta no importa todavía) que hace resistencia real al
## viento y genera su propia zona de calma a favor del viento.
##
## Mismo patrón que Player/NPC (Principio 1 del documento de visión):
## radio y altura son las únicas dos variables que existen. De ahí se
## derivan la malla, la forma de colisión, Y el tamaño de la zona de
## calma (ver VientoObstaculoMath) — nunca un tercer número suelto
## para "qué tan grande es la sombra de viento" que alguien deba
## mantener sincronizado a mano.
##
## Su identidad térmica reutiliza PerfilBioma (Principio 5): un
## obstáculo de roca es, térmicamente, el mismo tipo de dato que un
## bioma. No hace falta una clase nueva para eso.
##
## Diferencia deliberada con Player/NPC: ahí el origen del nodo está
## en el CENTRO de la cápsula (así lo necesita el controlador de
## personaje). Acá el origen está en la BASE — donde el objeto toca
## el suelo — porque así lo vas a arrastrar y soltar en el editor
## sobre el terreno, y porque la zona de calma se mide "desde la
## base" (tal como pediste). Son dos convenciones distintas a
## propósito, cada una correcta para lo que a esa entidad le toca hacer.

@export_group("Cuerpo")
@export var radio: float = 1.5
@export var altura: float = 2.0

@export_group("Identidad térmica")
@export var bioma: PerfilBioma

@export_group("Viento")
## Multiplica qué tan larga es la zona protegida detrás del
## obstáculo. Es el MISMO número que usa VientoObstaculoMath para
## calcular la zona real de deflexión — la cruceta de depuración y la
## física real nunca pueden desincronizarse entre sí porque ambas
## leen del mismo lugar.
@export var factor_largo_estela: float = 4.0

var temperatura: float = 15.0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	_build_body()
	if bioma != null:
		temperatura = bioma.temperatura_referencia
	add_to_group("obstaculo_viento")
	SimClock.tick.connect(_on_sim_tick)


func _build_body() -> void:
	var shape := CylinderShape3D.new()
	shape.radius = radio
	shape.height = altura
	collision_shape.shape = shape
	collision_shape.position = Vector3(0.0, altura * 0.5, 0.0)

	var mesh := CylinderMesh.new()
	mesh.top_radius = radio
	mesh.bottom_radius = radio
	mesh.height = altura
	mesh_instance.mesh = mesh
	mesh_instance.position = Vector3(0.0, altura * 0.5, 0.0)

	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0.47, 0.45)
	mesh_instance.material_override = material


func _on_sim_tick(delta_sim_seconds: float) -> void:
	if bioma == null:
		return
	var sol := get_tree().get_first_node_in_group("sol") as Sol
	var superficie_activa := get_tree().get_first_node_in_group("superficie_activa") as Superficie
	if sol == null or superficie_activa == null:
		return

	var pos: Dictionary = SolarMath.calcular_elevacion_acimut(SimClock.hour_of_day, superficie_activa.ubicacion.latitude_degrees, Sol.DECLINATION_DEGREES)
	var day_factor: float = clamp(pos.sin_elevation, 0.0, 1.0)
	var radiacion: float = ThermalMath.calcular_radiacion(day_factor, sol.max_radiacion, bioma, superficie_activa.ubicacion.altitude_meters)
	temperatura += ThermalMath.calcular_delta_temperatura(temperatura, radiacion, bioma, delta_sim_seconds)


## Punto de consulta público: cuál es el viento real (ya deflectado
## por este obstáculo) en un punto cualquiera del mundo, dado el
## viento regional sin perturbar. Lo usan tanto la cruceta de
## depuración como, más adelante, cualquier sistema que necesite
## saber "qué viento hay realmente acá" (por ejemplo, un futuro
## componente de necesidades de fauna).
func viento_en_punto_global(punto_global: Vector3, direccion_regional: Vector3, velocidad_regional: float) -> Vector3:
	var punto_relativo: Vector3 = punto_global - global_position
	return VientoObstaculoMath.deflectar(punto_relativo, direccion_regional, velocidad_regional, radio, altura, factor_largo_estela)
