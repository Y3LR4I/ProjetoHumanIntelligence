extends Area2D

@export var speed: float = 600.0

func _physics_process(delta):
	position.y -= speed * delta

func _on_area_entered(area):
	if area.name == "LaserExit":
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "MaintenanceRobot":
		var health_component = body.get_node("HealthComponent")
		health_component.take_damage(0.5)
		queue_free()
