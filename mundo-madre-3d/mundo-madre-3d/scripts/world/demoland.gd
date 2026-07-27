class_name DemoLand
extends Node3D
## Un mapa jugable — una región del mundo con sus propias
## características (ubicación, tipo de terreno, entidades). El
## terreno se arma a mano en el editor (nodo Ground), no por código.
##
## Expone su temperatura de superficie y de aire para que Main pueda
## mostrarla en el HUD sin necesitar saber cómo está armado por dentro
## — Main solo pregunta "¿sabés reportar tu temperatura?", nunca
## asume la existencia de nodos internos específicos de este mapa.

@onready var superficie: Superficie = $Ground
@onready var aire: AireLocal = $AireLocal
@onready var viento: VientoRegional = $VientoRegional

func obtener_velocidad_viento() -> float:
	return viento.velocidad

func obtener_temperatura_superficie() -> float:
	return superficie.temperatura

func obtener_temperatura_aire() -> float:
	return aire.temperatura

func obtener_radiacion_recibida() -> float:
	return superficie.radiacion_recibida

func obtener_info_bioma() -> Dictionary:
	return {
		"nombre": superficie.bioma.nombre,
		"resistencia_termica": superficie.bioma.resistencia_termica,
		"albedo": superficie.bioma.albedo,
	}
