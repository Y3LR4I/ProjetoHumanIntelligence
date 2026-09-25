extends Node

@export var max_health: float = 4.0

var health: float


func _ready():
	health = max_health


func take_damage(amount: float):
	health -= amount
	
	if health <= 0:
		get_parent().queue_free()
