extends Node

@export var enemy_scenes: Array[PackedScene]
@export var spawn_x_min: float = 220.0
@export var spawn_x_max: float = 1060.0
@export var spawn_y: float = -80.0
@export var initial_interval: float = 2.2
@export var min_interval: float = 0.7
@export var ramp_duration: float = 120.0

@onready var spawn_timer = $SpawnTimer

var _elapsed: float = 0.0
var _running: bool = false

func start() -> void:
	_running = true
	_elapsed = 0.0
	_schedule_next_spawn()

func stop() -> void:
	_running = false
	spawn_timer.stop()

func _process(delta: float) -> void:
	if _running:
		_elapsed += delta

func _schedule_next_spawn() -> void:
	if not _running:
		return

	var progress = clamp(_elapsed / ramp_duration, 0.0, 1.0)
	spawn_timer.wait_time = lerp(initial_interval, min_interval, progress)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()
	_schedule_next_spawn()

func _spawn_enemy() -> void:
	if enemy_scenes.is_empty():
		return

	var scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = scene.instantiate()
	enemy.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	get_tree().current_scene.add_child(enemy)
