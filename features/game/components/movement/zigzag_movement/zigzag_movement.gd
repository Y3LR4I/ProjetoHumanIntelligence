extends Node

@export var vertical_speed: float = 150.0
@export var horizontal_amplitude: float = 160.0
@export var horizontal_frequency: float = 1.8

@onready var enemy = get_parent()

var _elapsed: float = 0.0

func _physics_process(delta):
	_elapsed += delta
	enemy.velocity.y = vertical_speed
	enemy.velocity.x = cos(_elapsed * horizontal_frequency) * horizontal_amplitude
	enemy.move_and_slide()
