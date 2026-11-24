extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var walk_frames_stage0: Array[Texture2D]
@export var walk_frames_stage1: Array[Texture2D]
@export var walk_frames_stage2: Array[Texture2D]
@export var walk_frames_stage3: Array[Texture2D]
@export var spread_angles_degrees: Array[float] = [-25.0, 0.0, 25.0]
@export var velocidade_base: float = 80.0

@onready var sprite = $Sprite2D
@onready var health_component = $HealthComponent
@onready var shoot_timer = $ShootTimer
@onready var walk_timer = $WalkTimer
@onready var zigzag_movement = $zigzag_movement

var _walk_sets: Array
var _current_walk_frames: Array[Texture2D]
var _walk_frame_index: int = 0
var _shoot_interval_base: float
var _intervalo_tiro_mult: float = 1.0
var _velocidade_projetil_mult: float = 1.0

func _ready():
	add_to_group("inimigos")
	_walk_sets = [walk_frames_stage0, walk_frames_stage1, walk_frames_stage2, walk_frames_stage3]
	_set_walk_stage(0)
	_shoot_interval_base = shoot_timer.wait_time
	health_component.health_changed.connect(_on_health_changed)
	_aplicar_velocidade()

func configurar_dificuldade(config: Dictionary) -> void:
	velocidade_base = config.get("velocidade", velocidade_base)
	_intervalo_tiro_mult = config.get("intervalo_tiro_mult", 1.0)
	_velocidade_projetil_mult = config.get("velocidade_projetil_mult", 1.0)
	_aplicar_velocidade()
	shoot_timer.wait_time = _shoot_interval_base * _intervalo_tiro_mult

func _aplicar_velocidade() -> void:
	zigzag_movement.vertical_speed = velocidade_base

func atirar():
	for angle_degrees in spread_angles_degrees:
		var projectile = projectile_scene.instantiate()
		projectile.direction = Vector2.DOWN.rotated(deg_to_rad(angle_degrees))
		projectile.speed *= _velocidade_projetil_mult
		projectile.global_position = $ProjectileSpawn.global_position
		get_tree().current_scene.add_child(projectile)

func _on_shoot_timer_timeout() -> void:
	atirar()

func _on_walk_timer_timeout() -> void:
	_walk_frame_index = (_walk_frame_index + 1) % _current_walk_frames.size()
	sprite.texture = _current_walk_frames[_walk_frame_index]

func _set_walk_stage(index: int) -> void:
	_current_walk_frames = _walk_sets[index]
	_walk_frame_index = 0
	sprite.texture = _current_walk_frames[0]

func _on_health_changed(health: float) -> void:
	var index = int(health_component.max_health - health)

	if index >= _walk_sets.size():
		index = _walk_sets.size() - 1

	_set_walk_stage(index)

	if index == _walk_sets.size() - 1:
		shoot_timer.stop()

func destruir_na_borda() -> void:
	shoot_timer.stop()
	walk_timer.stop()
	await get_tree().create_timer(0.3).timeout

	sprite.texture = walk_frames_stage2[0]

	await get_tree().create_timer(0.2).timeout

	sprite.texture = walk_frames_stage3[0]

	await get_tree().create_timer(0.2).timeout

	queue_free()
