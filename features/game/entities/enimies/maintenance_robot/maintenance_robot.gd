extends CharacterBody2D

@export var projectile_scene: PackedScene

func atirar():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = $ProjectileSpawn.global_position
	get_tree().current_scene.add_child(projectile)


func _on_shoot_timer_timeout() -> void:
	atirar()
