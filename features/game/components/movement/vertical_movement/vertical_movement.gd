extends Node

@export var speed: float = 100.0

@onready var enemy = get_parent()

func _physics_process(_delta):
	enemy.velocity.y = speed
	enemy.move_and_slide()
