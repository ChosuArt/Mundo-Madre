class_name AireLocal
extends Node
## El aire local sobre una superficie de mapa — segundo eslabón de la
## cadena Sol → Tierra/Mar → Aire. A propósito NO recibe radiación
## solar directamente: se calienta por contacto con la superficie que
## tiene debajo, tal como corregiste.

@export var superficie: Superficie
@export var resistencia_termica: float = 6.0
## A qué temperatura tiende cuando pierde contacto con toda fuente de
## calor — simplificación de la pérdida hacia capas más altas.
@export var temperatura_perdida: float = 5.0

var temperatura: float = 20.0


func _ready() -> void:
	SimClock.tick.connect(_on_sim_tick)


func _on_sim_tick(delta_sim_seconds: float) -> void:
	var ganancia_de_superficie: float = (superficie.temperatura - temperatura) * 0.3
	var perdida_hacia_arriba: float = (temperatura - temperatura_perdida) * 0.05
	var delta_temp: float = (ganancia_de_superficie - perdida_hacia_arriba) / resistencia_termica
	temperatura += delta_temp * (delta_sim_seconds / 3600.0)
