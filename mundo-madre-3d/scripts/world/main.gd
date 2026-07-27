extends Node3D
## Raíz del juego — NO es un mapa, es lo que le permite al jugador ver
## cualquier mapa. Contiene lo que vale para cualquier zona (cámara,
## HUD, el Sol como cuerpo celeste compartido por todo el planeta) y
## un contenedor donde se instancia el mapa activo.

@export var initial_map: PackedScene

@export_group("Cámara de observación")
@export var camera_look_at: Vector3 = Vector3(2.5, 0.0, 2.5)
@export var camera_yaw_degrees: float = 45.0
@export var camera_pitch_degrees: float = -40.0
@export var camera_distance: float = 18.0

@onready var time_label: Label = $HUD/TimeLabel
@onready var sol: Sol = $Sol
@onready var map_container: Node3D = $MapaActual

var _current_map: Node = null


func _ready() -> void:
	_build_environment()
	_build_camera()
	if initial_map != null:
		switch_map(initial_map)


func _process(_delta: float) -> void:
	_update_time_label()


func switch_map(new_map_scene: PackedScene) -> void:
	if _current_map != null:
		_current_map.queue_free()

	_current_map = new_map_scene.instantiate()
	map_container.add_child(_current_map)


func _update_time_label() -> void:
	var hours: int = int(SimClock.hour_of_day)
	var minutes: int = int((SimClock.hour_of_day - hours) * 60.0)
	var texto: String = "Día %d — %02d:%02d  |  Sol %.0f°" % [
		SimClock.day_number + 1, hours, minutes, sol.elevation_degrees
	]
	if _current_map != null and _current_map.has_method("obtener_temperatura_superficie"):
		texto += "  |  Superficie %.1f°C  |  Aire %.1f°C  |  Viento %.1f" % [
			_current_map.obtener_temperatura_superficie(),
			_current_map.obtener_temperatura_aire(),
			_current_map.obtener_velocidad_viento()
		]
	time_label.text = texto


func _build_camera() -> void:
	var pivot := Node3D.new()
	pivot.name = "CameraPivot"
	pivot.position = camera_look_at
	pivot.rotation_degrees = Vector3(camera_pitch_degrees, camera_yaw_degrees, 0.0)
	add_child(pivot)

	var camera := Camera3D.new()
	camera.name = "ObserverCamera"
	camera.position = Vector3(0.0, 0.0, camera_distance)
	camera.current = true
	pivot.add_child(camera)


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
