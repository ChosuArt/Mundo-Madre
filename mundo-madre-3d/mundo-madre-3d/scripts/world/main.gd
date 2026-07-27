extends Node3D
## Raíz del juego — NO es un mapa, es lo que le permite al jugador ver
## cualquier mapa. Contiene lo que vale para cualquier zona (cámara,
## HUD, el Sol como cuerpo celeste compartido por todo el planeta) y
## un contenedor donde se instancia el mapa activo.

@export var initial_map: PackedScene

@export_group("Cámara libre (provisional, de desarrollo)")
@export var camera_start_position: Vector3 = Vector3(0, 6, 14)
@export var camera_start_pitch_degrees: float = -25.0

@onready var time_label: Label = $HUD/TimeLabel
@onready var sol: Sol = $Sol
@onready var map_container: Node3D = $MapaActual

var _current_map: Node = null


func _ready() -> void:
	_build_environment()
	_build_camera()
	_build_hud()
	if initial_map != null:
		switch_map(initial_map)

func _process(_delta: float) -> void:
	_update_time_label()

func switch_map(new_map_scene: PackedScene) -> void:
	if _current_map != null:
		_current_map.queue_free()

	_current_map = new_map_scene.instantiate()
	map_container.add_child(_current_map)

func _build_hud() -> void:
	time_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	time_label.offset_bottom = 340.0

func _update_time_label() -> void:
	var hours: int = int(SimClock.hour_of_day)
	var minutes: int = int((SimClock.hour_of_day - hours) * 60.0)
	var lineas: Array[String] = []
	lineas.append("Día %d — %02d:%02d" % [SimClock.day_number + 1, hours, minutes])
	lineas.append("Sol: %.0f°" % sol.elevation_degrees)

	if _current_map != null and _current_map.has_method("obtener_temperatura_superficie"):
		lineas.append("Temp. terreno: %.1f°C" % _current_map.obtener_temperatura_superficie())
	if _current_map != null and _current_map.has_method("obtener_temperatura_aire"):
		lineas.append("Temp. aire: %.1f°C" % _current_map.obtener_temperatura_aire())
	if _current_map != null and _current_map.has_method("obtener_velocidad_viento"):
		lineas.append("Viento: %.1f m/s" % _current_map.obtener_velocidad_viento())
	if _current_map != null and _current_map.has_method("obtener_radiacion_recibida"):
		lineas.append("Radiación entrante: %.0f W/m²" % _current_map.obtener_radiacion_recibida())
	if _current_map != null and _current_map.has_method("obtener_info_bioma"):
		var info: Dictionary = _current_map.obtener_info_bioma()
		lineas.append("Bioma: %s (resist. térm. %.1f, albedo %.2f)" % [info.nombre, info.resistencia_termica, info.albedo])

	time_label.text = "\n".join(lineas)

func _build_camera() -> void:
	var camara := CamaraLibre.new()
	camara.name = "CamaraLibre"
	camara.position = camera_start_position
	camara.rotation_degrees = Vector3(camera_start_pitch_degrees, 0.0, 0.0)
	add_child(camara)

func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY

	var sky_material := ProceduralSkyMaterial.new()
	var sky := Sky.new()
	sky.sky_material = sky_material
	environment.sky = sky

	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
