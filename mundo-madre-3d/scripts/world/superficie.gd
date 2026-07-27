class_name Superficie
extends Node3D
## La superficie real de un mapa — primer eslabón de la cadena
## Sol → Tierra/Mar → Aire. Su identidad térmica y su ubicación ya no
## viven en campos sueltos: viven en un PerfilBioma y una
## CoordenadaGlobal (Resources) — el mismo patrón que usan los vecinos
## nominales del sistema de viento, para que ambos casos compartan una
## sola fórmula (ThermalMath), no dos implementaciones paralelas.

@export var ubicacion: CoordenadaGlobal
@export var bioma: PerfilBioma
@export var es_referencia_del_mapa: bool = false

var temperatura: float = 20.0
var radiacion_recibida: float = 0.0

@onready var sol: Sol = get_tree().get_first_node_in_group("sol") as Sol


func _ready() -> void:
	temperatura = bioma.temperatura_referencia
	if es_referencia_del_mapa:
		add_to_group("superficie_activa")
	SimClock.tick.connect(_on_sim_tick)


func _on_sim_tick(delta_sim_seconds: float) -> void:
	var pos: Dictionary = SolarMath.calcular_elevacion_acimut(SimClock.hour_of_day, ubicacion.latitude_degrees, Sol.DECLINATION_DEGREES)
	var day_factor: float = clamp(pos.sin_elevation, 0.0, 1.0)

	radiacion_recibida = ThermalMath.calcular_radiacion(day_factor, sol.max_radiacion, bioma, ubicacion.altitude_meters)
	temperatura += ThermalMath.calcular_delta_temperatura(temperatura, radiacion_recibida, bioma, delta_sim_seconds)
