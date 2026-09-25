extends Area2D

@export var speed: float = 200.0
@export var rotation_speed: float = 5.0

func _physics_process(delta):
	position.y += speed * delta
	rotation += rotation_speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyProjectileExit":
		queue_free()
