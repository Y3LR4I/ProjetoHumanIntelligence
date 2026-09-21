class_name EnemyData
extends Resource

@export var display_name: String = ""
@export var max_health: float = 1.0
@export var move_speed: float = 60.0
@export var contact_damage: float = 1.0
@export var has_ranged_attack: bool = false
@export var ranged_damage: float = 0.0
@export var ranged_interval: float = 2.0
@export var points_value: int = 10
@export var color: Color = Color.WHITE
@export var visual_size: Vector2 = Vector2(48, 48)
