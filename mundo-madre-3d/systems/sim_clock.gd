extends Node
## Reloj de Simulación — Etapa 1 de la hoja de ruta.
##
## Es el único Autoload (singleton) de todo el proyecto, y a propósito:
## no es una entidad del mundo con posición o identidad física, es la
## base temporal que todo lo demás (Sol, intercambio térmico) necesita
## leer sin tener que recibir una referencia manual en el Inspector.
## Cualquier otro sistema puede consultarlo como "SimClock.hora_del_dia"
## desde cualquier parte del árbol de nodos.
##
## Principio clave que resuelve: el reloj avanza a INTERVALOS FIJOS,
## independiente del framerate. Si el juego corre a 30 fps en una PC
## floja o a 240 fps en una gama alta, un día simulado debe durar lo
## mismo en ambos casos. Por eso no actualizamos el tiempo simulado
## directamente en cada frame de _process(): acumulamos tiempo real y
## solo "avanzamos" la simulación cada `tick_interval_seconds`, sin
## importar cuántos frames de render pasaron en el medio.

signal tick(delta_sim_seconds: float)
signal new_day(day_number: int)

@export_group("Reloj")
## Cada cuánto tiempo REAL (segundos) se procesa un paso de simulación.
## Es la "resolución" temporal del reloj — más chico es más preciso pero
## cuesta más CPU (Principio 7: la resolución se decide por costo medido,
## no por intuición).
@export var tick_interval_seconds: float = 0.1

## Cuántos segundos SIMULADOS avanza el mundo en cada paso.
@export var sim_seconds_per_tick: float = 60.0

@export_group("Estado inicial")
## Hora del día (0-24) al arrancar. 6.0 = amanecer, para ver algo de
## inmediato al correr la demo.
@export var hour_of_day: float = 6.0

var day_number: int = 0
var elapsed_sim_seconds: float = 0.0

var _accumulator: float = 0.0

const SECONDS_PER_DAY: float = 86400.0


func _ready() -> void:
	elapsed_sim_seconds = hour_of_day * 3600.0


func _process(delta: float) -> void:
	_accumulator += delta
	# El "while" (no "if") importa: si el juego se traba un instante y
	# el delta real es grande, procesamos varios ticks seguidos en vez
	# de perder tiempo de simulación silenciosamente.
	while _accumulator >= tick_interval_seconds:
		_accumulator -= tick_interval_seconds
		_advance(sim_seconds_per_tick)


func _advance(delta_sim: float) -> void:
	elapsed_sim_seconds += delta_sim
	hour_of_day = fmod(hour_of_day + delta_sim / 3600.0, 24.0)

	var new_day_number := int(elapsed_sim_seconds / SECONDS_PER_DAY)
	if new_day_number != day_number:
		day_number = new_day_number
		new_day.emit(day_number)

	tick.emit(delta_sim)
