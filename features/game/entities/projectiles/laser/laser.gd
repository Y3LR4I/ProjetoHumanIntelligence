extends Area2D

@export var speed: float = 600.0

func _physics_process(delta):
	position.y -= speed * delta

func _on_area_entered(area):
	if area.name == "LaserExit":
		queue_free()

	if area.name == "Wrench" or area.name == "Parafuso":
		area.queue_free()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name != "player" and body.has_node("HealthComponent"):
		body.get_node("HealthComponent").take_laser_hit()
		queue_free()
