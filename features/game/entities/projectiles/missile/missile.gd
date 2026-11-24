extends Area2D

## Míssil teleguiado disparado pelo Drone. Persegue o player só durante
## `homing_duration` segundos (com curva limitada por `turn_rate`) e depois
## segue reto — dá pra desviar se mexendo, ou derrubar com um tiro de laser.

@export var speed: float = 230.0
@export var damage: float = 1.0
@export var turn_rate: float = 2.4
@export var homing_duration: float = 1.1

var direction: Vector2 = Vector2.DOWN
var target: Node2D

var _elapsed: float = 0.0

func _ready() -> void:
	add_to_group("enemy_projectile")
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	_elapsed += delta

	if _elapsed < homing_duration and is_instance_valid(target):
		var desired: Vector2 = (target.global_position - global_position).normalized()
		var max_turn: float = turn_rate * delta
		direction = direction.rotated(clampf(direction.angle_to(desired), -max_turn, max_turn))

	position += direction * speed * delta
	rotation = direction.angle()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyProjectileExit":
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.get_node("HealthComponent").take_damage(damage)
		queue_free()
	elif body is StaticBody2D:
		queue_free()

func _on_life_timer_timeout() -> void:
	queue_free()
