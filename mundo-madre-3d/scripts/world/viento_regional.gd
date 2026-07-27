class_name VientoRegional
extends Node
## Motor de viento regional — Etapa 5 simplificada.
##
## No existe una "zona vecina" como escena: los biomas de alrededor
## son NOMINALES (un PerfilBioma fijo por cada uno de los 8 rumbos),
## representando la geografía real de la región a escala de
## kilómetros, sin que cada uno tenga que existir como geometría 3D
## propia. Aun así, cada vecino se integra con la MISMA fórmula
## térmica causal que usa la Superficie real (ThermalMath).
##
## El viento resultante es la suma de "desde dónde sopla" por cada
## vecino más frío que la Superficie local (aire frío = más denso =
## más presión = empuja hacia lo más cálido), más una deflexión de
## Coriolis derivada de la latitud real del mapa.

@export var superficie: Superficie

@export_group("Biomas vecinos (nominales, fijos por diseño)")
@export var bioma_norte: PerfilBioma
@export var bioma_noreste: PerfilBioma
@export var bioma_este: PerfilBioma
@export var bioma_sureste: PerfilBioma
@export var bioma_sur: PerfilBioma
@export var bioma_suroeste: PerfilBioma
@export var bioma_oeste: PerfilBioma
@export var bioma_noroeste: PerfilBioma

@export_group("Ajuste")
@export var sensibilidad: float = 0.2
@export var velocidad_maxima: float = 12.0
## Deflexión máxima por Coriolis, en grados, alcanzada cerca de los
## polos. Simplificación consciente: el efecto real también depende
## de la velocidad del viento, no solo de la latitud.
@export var deflexion_coriolis_maxima_grados: float = 30.0

var direccion: Vector3 = Vector3.ZERO
var velocidad: float = 0.0

# Direcciones unitarias fijas — convención del proyecto: Norte = -Z,
# Este = +X, arriba = +Y.
const _DIRECCIONES := {
	"norte": Vector3(0, 0, -1),
	"noreste": Vector3(1, 0, -1),
	"este": Vector3(1, 0, 0),
	"sureste": Vector3(1, 0, 1),
	"sur": Vector3(0, 0, 1),
	"suroeste": Vector3(-1, 0, 1),
	"oeste": Vector3(-1, 0, 0),
	"noroeste": Vector3(-1, 0, -1),
}

# Temperatura interna de cada vecino nominal — se integra cada tick
# igual que una Superficie real, solo que no vive en un nodo propio.
var _temperaturas_vecinos: Dictionary = {}


func _ready() -> void:
	for nombre_rumbo in _DIRECCIONES.keys():
		var bioma: PerfilBioma = get(&"bioma_%s" % nombre_rumbo)
		if bioma != null:
			_temperaturas_vecinos[nombre_rumbo] = bioma.temperatura_referencia
	SimClock.tick.connect(_on_sim_tick)


func _on_sim_tick(delta_sim_seconds: float) -> void:
	var pos: Dictionary = SolarMath.calcular_elevacion_acimut(SimClock.hour_of_day, superficie.ubicacion.latitude_degrees, Sol.DECLINATION_DEGREES)
	var day_factor: float = clamp(pos.sin_elevation, 0.0, 1.0)

	var vector_resultante := Vector3.ZERO

	for nombre_rumbo in _DIRECCIONES.keys():
		var bioma: PerfilBioma = get(&"bioma_%s" % nombre_rumbo)
		if bioma == null:
			continue

		var radiacion: float = ThermalMath.calcular_radiacion(day_factor, 1000.0, bioma, superficie.ubicacion.altitude_meters)
		var temp_actual: float = _temperaturas_vecinos[nombre_rumbo]
		temp_actual += ThermalMath.calcular_delta_temperatura(temp_actual, radiacion, bioma, delta_sim_seconds)
		_temperaturas_vecinos[nombre_rumbo] = temp_actual

		var diferencia: float = superficie.temperatura - temp_actual
		if diferencia > 0.0:
			# El vecino está más frío: el viento SOPLA DESDE ese rumbo.
			vector_resultante -= _DIRECCIONES[nombre_rumbo].normalized() * diferencia

	var velocidad_bruta: float = vector_resultante.length()
	velocidad = clamp(velocidad_bruta * sensibilidad, 0.0, velocidad_maxima)

	if velocidad_bruta > 0.0001:
		direccion = _aplicar_coriolis(vector_resultante.normalized(), superficie.ubicacion.latitude_degrees)


func _aplicar_coriolis(vector: Vector3, latitude_degrees: float) -> Vector3:
	# Hemisferio norte: deflexión hacia la derecha. Hemisferio sur:
	# hacia la izquierda. Magnitud proporcional a la distancia al
	# ecuador (0 en el ecuador, máxima cerca de los polos).
	var factor: float = clamp(latitude_degrees / 90.0, -1.0, 1.0)
	var angulo: float = deg_to_rad(deflexion_coriolis_maxima_grados * factor)
	return vector.rotated(Vector3.UP, -angulo)
