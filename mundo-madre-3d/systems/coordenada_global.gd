class_name CoordenadaGlobal
extends Resource
## Sistema de coordenadas propio del proyecto — Godot no trae uno
## para geografía planetaria, así que lo definimos una sola vez acá y
## lo reutiliza cualquier Superficie de cualquier mapa futuro.
##
## No pretende precisión geodésica real: alcanza con ubicar cada mapa
## dentro de una franja amplia (del orden de kilómetros, no metros).
## Lo que le importa a la simulación es la posición RELATIVA entre
## mapas y el efecto de la latitud sobre el sol y el Coriolis — no
## coordenadas exactas tipo GPS.

@export var latitude_degrees: float = 8.0
@export var longitude_degrees: float = 0.0
@export var altitude_meters: float = 150.0
