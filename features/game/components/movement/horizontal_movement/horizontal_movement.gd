extends Node

@export var speed: float = 300.0

@onready var player = get_parent()

func _physics_process(_delta):
	var direction = Input.get_axis("move_left", "move_right")
	player.velocity.x = direction * speed
	player.move_and_slide()
