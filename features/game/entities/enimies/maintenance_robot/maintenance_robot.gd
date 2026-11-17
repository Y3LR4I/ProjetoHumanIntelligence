extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var health_sprites: Array[Texture2D]
@export var velocidade_base: float = 80.0

@onready var sprite = $Sprite2D
@onready var health_component = $HealthComponent
@onready var vertical_movement = $verical_movement
@onready var shoot_timer = $ShootTimer

func _ready():
	add_to_group("inimigos")
	health_component.health_changed.connect(_on_health_changed)
	_aplicar_velocidade()

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
	
	if index == 3:
		shoot_timer.stop()

	_aplicar_velocidade()

func configurar_dificuldade(velocidade: float) -> void:
	velocidade_base = velocidade
	_aplicar_velocidade()

func _aplicar_velocidade() -> void:
	var health = health_component.health
	var multiplicador = 1.0

	if health > 3.0:
		multiplicador = 1.0
	elif health > 2.0:
		multiplicador = 0.75
	elif health > 1.0:
		multiplicador = 0.25
	else:
		multiplicador = 0.025

	vertical_movement.speed = velocidade_base * multiplicador

func destruir_na_borda() -> void:
	shoot_timer.stop()
	await get_tree().create_timer(0.3).timeout
	
	sprite.texture = health_sprites[health_sprites.size() - 2]
	
	await get_tree().create_timer(0.2).timeout
	
	sprite.texture = health_sprites[health_sprites.size() - 1]
	
	await get_tree().create_timer(0.2).timeout
	
	queue_free()
