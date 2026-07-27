class_name Sol
extends Node3D
## El Sol como Cuerpo Celeste — Etapa 4 de la hoja de ruta.
##
## Ya no tiene latitud propia. Antes existían dos números que debían
## coincidir a mano (uno acá, otro en Superficie) y nada avisaba si se
## desincronizaban — eso ya no puede pasar: Sol busca en cada tick la
## Superficie marcada como "referencia del mapa" y usa SU latitud.
## Una sola fuente de verdad. Cuando exista más de un mapa (Etapa 8),
## este mismo mecanismo es lo que hace que el cielo se oriente según
## el mapa que esté activo en cada momento.

@export_group("Luz (presentación visual)")
@export var max_light_energy: float = 1.2

@export_group("Constante solar (dato global real)")
@export var max_radiacion: float = 1000.0

const DECLINATION_DEGREES: float = 0.0

@onready var light: DirectionalLight3D = $DirectionalLight3D

var elevation_degrees: float = 0.0
var azimuth_degrees: float = 0.0


func _ready() -> void:
	light.shadow_enabled = true
	add_to_group("sol")
	SimClock.tick.connect(_on_sim_tick)


func _on_sim_tick(_delta_sim_seconds: float) -> void:
	var superficie_activa := get_tree().get_first_node_in_group("superficie_activa") as Superficie
	if superficie_activa == null:
		return
	_update_light(SimClock.hour_of_day, superficie_activa.ubicacion.latitude_degrees)


func _update_light(hour_of_day: float, latitude_degrees: float) -> void:
	var pos: Dictionary = SolarMath.calcular_elevacion_acimut(hour_of_day, latitude_degrees, DECLINATION_DEGREES)
	elevation_degrees = pos.elevation_degrees
	azimuth_degrees = pos.azimuth_degrees

	var elevation_rad: float = deg_to_rad(elevation_degrees)
	var azimuth_rad: float = deg_to_rad(azimuth_degrees)
	var cos_elevation: float = cos(elevation_rad)

	var direction_to_sun: Vector3 = Vector3(
		cos_elevation * sin(azimuth_rad),
		sin(elevation_rad),
		-cos_elevation * cos(azimuth_rad)
	)

	if direction_to_sun.length_squared() > 0.0001:
		light.look_at(light.global_position - direction_to_sun, Vector3.UP)

	var day_factor: float = clamp(pos.sin_elevation, 0.0, 1.0)
	light.light_energy = max_light_energy * day_factor
