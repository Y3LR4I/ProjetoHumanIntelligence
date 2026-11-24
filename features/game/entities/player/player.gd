extends CharacterBody2D

signal shot_fired

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const AUTO_FIRE_INTERVAL = 0.35

var _auto_fire_timer := 0.0

@export var laser_scene: PackedScene
@onready var laser_spawn = $LaserSpawn
@onready var health_component = $HealthComponent
@onready var shoot_sound = $ShootSound
@onready var laser_cannon = $LaserCannon
@onready var shield = $Shield
@onready var heal_sound = $HealSound
@onready var heal_particles = $HealParticles
@onready var battery = get_tree().current_scene.get_node("HUD/Battery")

func _ready():
	add_to_group("player")
	health_component.health_changed.connect(_on_health_changed)

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	# Enquanto o canhão laser está ativo o tiro normal fica bloqueado.
	if not laser_cannon.is_active():
		if Input.is_action_just_pressed("shoot"):
			atirar()
			_auto_fire_timer = AUTO_FIRE_INTERVAL
		elif Input.is_action_pressed("shoot"):
			_auto_fire_timer -= delta
			if _auto_fire_timer <= 0.0:
				atirar()
				_auto_fire_timer = AUTO_FIRE_INTERVAL
		else:
			_auto_fire_timer = 0.0
	if Input.is_action_just_pressed("power_laser_cannon"):
		laser_cannon.try_activate()
	if Input.is_action_just_pressed("power_shield"):
		shield.try_activate()
		
	move_and_slide()

func atirar():
	var laser = laser_scene.instantiate()
	laser.global_position = laser_spawn.global_position
	get_tree().current_scene.add_child(laser)
	shoot_sound.play()
	shot_fired.emit()
	
## Chamado pelos pickups. Retorna true se o upgrade foi aproveitado.
func receber_upgrade(power_id: StringName, value: float = 1.0) -> bool:
	match power_id:
		&"shield":
			return shield.add_charge()
		&"battery":
			if not health_component.can_receive_heal():
				return false
			health_component.heal(value)
			heal_sound.play()
			heal_particles.restart()
			return true
	return false

func _on_health_changed(health: float) -> void:
	battery.update_health(health)
