extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var walk_frames_stage0: Array[Texture2D]
@export var walk_frames_stage1: Array[Texture2D]
@export var walk_frames_stage2: Array[Texture2D]
@export var walk_frames_stage3: Array[Texture2D]
@export var spread_angles_degrees: Array[float] = [-25.0, 0.0, 25.0]

@onready var sprite = $Sprite2D
@onready var health_component = $HealthComponent
@onready var shoot_timer = $ShootTimer
@onready var walk_timer = $WalkTimer

var _walk_sets: Array
var _current_walk_frames: Array[Texture2D]
var _walk_frame_index: int = 0

func _ready():
	_walk_sets = [walk_frames_stage0, walk_frames_stage1, walk_frames_stage2, walk_frames_stage3]
	_set_walk_stage(0)
	health_component.health_changed.connect(_on_health_changed)

func atirar():
	for angle_degrees in spread_angles_degrees:
		var projectile = projectile_scene.instantiate()
		projectile.direction = Vector2.DOWN.rotated(deg_to_rad(angle_degrees))
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
