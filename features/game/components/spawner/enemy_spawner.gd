extends Node

signal enemy_spawned(enemy: Node)

@export var enemy_scenes: Array[PackedScene]
@export var spawn_x_min: float = 220.0
@export var spawn_x_max: float = 1060.0
@export var spawn_y: float = -80.0

@onready var spawn_timer = $SpawnTimer

var _config: Dictionary = {}
var _running: bool = false

func start() -> void:
	_running = true
	_schedule_next_spawn()

func stop() -> void:
	_running = false
	spawn_timer.stop()

func configurar_dificuldade(config: Dictionary) -> void:
	_config = config
	_aplicar_dificuldade_em_todos()

	if _running:
		_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	if not _running:
		return

	spawn_timer.wait_time = _config.get("intervalo_spawn", 2.2)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()
	_schedule_next_spawn()

func _spawn_enemy() -> void:
	if enemy_scenes.is_empty():
		return

	var max_inimigos = int(_config.get("max_inimigos", 999))
	if get_tree().get_nodes_in_group("inimigos").size() >= max_inimigos:
		return

	var scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = scene.instantiate()
	enemy.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	get_tree().current_scene.add_child(enemy)
	enemy_spawned.emit(enemy)

	if enemy.has_method("configurar_dificuldade"):
		enemy.configurar_dificuldade(_config)

func _aplicar_dificuldade_em_todos() -> void:
	for enemy in get_tree().get_nodes_in_group("inimigos"):
		if is_instance_valid(enemy) and enemy.has_method("configurar_dificuldade"):
			enemy.configurar_dificuldade(_config)
