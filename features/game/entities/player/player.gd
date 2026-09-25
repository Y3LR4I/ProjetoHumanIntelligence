extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var laser_scene: PackedScene

@onready var laser_spawn = $LaserSpawn


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if Input.is_action_just_pressed("shoot"):
		atirar()
		
	move_and_slide()

func atirar():
	var laser = laser_scene.instantiate()
	laser.global_position = laser_spawn.global_position
	
	get_tree().current_scene.add_child(laser)
