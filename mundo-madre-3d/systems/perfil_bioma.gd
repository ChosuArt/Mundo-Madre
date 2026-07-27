class_name PerfilBioma
extends Resource
## Identidad térmica de un tipo de bioma — mar, bosque, llanura,
## desierto, etc. Es DATO, no código: define cómo reacciona un tipo de
## superficie ante la misma radiación solar. El mismo componente
## (Superficie real, o un vecino nominal del sistema de viento) se
## comporta distinto según qué Resource tenga asignado — Principio 5:
## composición sobre herencia.

@export var nombre: String = "Llanura"
@export_range(0.0, 1.0) var albedo: float = 0.25
@export var resistencia_termica: float = 4.0
## A qué temperatura tiende esta superficie sin aporte solar directo.
@export var temperatura_referencia: float = 12.0
