extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var health_sprites: Array[Texture2D]

@onready var sprite = $Sprite2D
@onready var health_component = $HealthComponent
@onready var vertical_movement = $verical_movement

func _ready():
	health_component.health_changed.connect(_on_health_changed)

func atirar():
	var projectile = projectile_scene.instantiate()
	projectile.global_position = $ProjectileSpawn.global_position
	get_tree().current_scene.add_child(projectile)

func _on_shoot_timer_timeout() -> void:
	atirar()

func _on_health_changed(health: float) -> void:
	var index = int(health_component.max_health - health)
	
	if index >= health_sprites.size():
		index = health_sprites.size() - 1
	
	sprite.texture = health_sprites[index]
	
	if health > 3.0:
		vertical_movement.speed = 80.0
	elif health > 2.0:
		vertical_movement.speed = 60.0
	elif health > 1.0:
		vertical_movement.speed = 20.0
	else:
		vertical_movement.speed = 2.0
