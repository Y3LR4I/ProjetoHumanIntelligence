extends Node

signal health_changed(health)
signal died

@export var max_health: float = 4.0
@export var laser_damage: float = 0.5

var health: float

func _ready():
	health = max_health

func take_damage(amount: float):
	health -= amount
	health_changed.emit(health)

	if health <= 0:
		died.emit()

		var parent = get_parent()
		if parent.has_node("ScoreComponent"):
			ScoreManager.adicionar_pontos(parent.get_node("ScoreComponent").score)

		parent.queue_free()

func take_laser_hit() -> void:
	take_damage(laser_damage)
