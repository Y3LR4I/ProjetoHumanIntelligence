extends Area2D

@export var speed: float = 260.0
@export var damage: float = 2.0
@export var direction: Vector2 = Vector2.DOWN

func _physics_process(delta):
	position += direction * speed * delta
	rotation += 6.0 * delta

func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyProjectileExit":
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player":
		var health_component = body.get_node("HealthComponent")
		health_component.take_damage(damage)

		queue_free()

func _on_life_timer_timeout() -> void:
	queue_free()
