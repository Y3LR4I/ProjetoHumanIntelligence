extends Area2D

## Upgrade que cai dos robôs destruídos. Desce devagar balançando; se o player
## encostar, entrega `power_id` pra ele (player.receber_upgrade) e some.

@export var power_id: StringName = &"shield"
@export var fall_speed: float = 90.0
@export var sway_speed: float = 22.0
@export var glow_color: Color = Color(0.3, 0.85, 1.0)
@export var glow_radius: float = 26.0

@onready var sprite: Sprite2D = $Sprite2D

var _time: float = 0.0
var _base_scale: Vector2

func _ready() -> void:
	add_to_group("pickups")
	_base_scale = sprite.scale

func _physics_process(delta: float) -> void:
	_time += delta
	position += Vector2(cos(_time * 2.5) * sway_speed, fall_speed) * delta
	sprite.scale = _base_scale * (1.0 + 0.08 * sin(_time * 6.0))
	queue_redraw()

func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_time * 6.0)
	draw_circle(Vector2.ZERO, glow_radius + 4.0 * pulse, Color(glow_color, 0.18 + 0.12 * pulse))
	draw_arc(Vector2.ZERO, glow_radius + 4.0 * pulse, 0.0, TAU, 40, Color(glow_color, 0.8), 2.0, true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("receber_upgrade"):
		if body.receber_upgrade(power_id):
			queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyProjectileExit":
		queue_free()
