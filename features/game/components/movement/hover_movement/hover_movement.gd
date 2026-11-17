extends Node

## Movimento de inimigo voador: desce até uma altura de "patrulha", fica
## pairando e balançando de um lado pro outro por um tempo, e depois volta a
## descer devagar até a borda inferior.

signal hover_started
signal hover_finished

enum State { ENTERING, HOVERING, EXITING }

@export var entry_speed: float = 170.0
@export var hover_y_min: float = 110.0
@export var hover_y_max: float = 230.0
@export var hover_duration: float = 7.0
@export var exit_speed: float = 55.0
@export var sway_speed: float = 90.0
@export var sway_frequency: float = 1.1
@export var bob_speed: float = 14.0

@onready var enemy: CharacterBody2D = get_parent()

var _state: State = State.ENTERING
var _hover_y: float
var _hover_elapsed: float = 0.0
var _elapsed: float = 0.0
var _phase: float

func _ready() -> void:
	_hover_y = randf_range(hover_y_min, hover_y_max)
	_phase = randf() * TAU

func _physics_process(delta: float) -> void:
	_elapsed += delta
	var sway: float = cos(_elapsed * sway_frequency + _phase) * sway_speed

	match _state:
		State.ENTERING:
			enemy.velocity = Vector2(0.0, entry_speed)
			if enemy.global_position.y >= _hover_y:
				_state = State.HOVERING
				hover_started.emit()
		State.HOVERING:
			_hover_elapsed += delta
			enemy.velocity = Vector2(sway, sin(_elapsed * 2.0) * bob_speed)
			if _hover_elapsed >= hover_duration:
				_state = State.EXITING
				hover_finished.emit()
		State.EXITING:
			enemy.velocity = Vector2(sway * 0.5, exit_speed)

	enemy.move_and_slide()

func is_hovering() -> bool:
	return _state == State.HOVERING
