extends Node

@export var damage: float = 1.0

func causar_dano(player):
	var health_component = player.get_node("HealthComponent")
	health_component.take_damage(damage)
