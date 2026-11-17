extends Node2D

## Poder "Escudo": precisa de uma carga, que vem do upgrade que cai dos robôs
## destruídos. Ativado, deixa o player invulnerável por `duration` segundos.
## Nos últimos segundos a bolha pisca, avisando que vai acabar.

signal status_changed(state: StringName, remaining: float, total: float)

const STATE_EMPTY: StringName = &"empty"
const STATE_READY: StringName = &"ready"
const STATE_ACTIVE: StringName = &"active"

@export var duration: float = 8.0
@export var max_charges: int = 1
@export var radius: float = 46.0
## Tempo final em que a bolha pisca avisando que vai acabar.
@export var warning_time: float = 2.0
@export var color: Color = Color(0.3, 0.85, 1.0)
## HealthComponent do player — o escudo liga/desliga a invulnerabilidade dele.
@export var health_component: Node

@export_group("Sprites")
## Sprite da bolha do escudo. Vazio = bolha provisória desenhada em código.
@export var shield_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var activate_sound: AudioStreamPlayer = $ActivateSound
@onready var block_sound: AudioStreamPlayer = $BlockSound
@onready var end_sound: AudioStreamPlayer = $EndSound
@onready var charge_sound: AudioStreamPlayer = $ChargeSound

var charges: int = 0

var _state: StringName = STATE_EMPTY
var _remaining: float = 0.0
var _time: float = 0.0
var _hit_flash: float = 0.0

func _ready() -> void:
	if shield_texture:
		sprite.texture = shield_texture
	sprite.visible = false
	health_component.damage_blocked.connect(_on_damage_blocked)
	_emit_status.call_deferred()

func is_active() -> bool:
	return _state == STATE_ACTIVE

func can_receive_charge() -> bool:
	return charges < max_charges

func add_charge() -> bool:
	if not can_receive_charge():
		return false

	charges += 1
	charge_sound.play()
	if _state == STATE_EMPTY:
		_state = STATE_READY
	_emit_status()
	return true

func try_activate() -> bool:
	if _state != STATE_READY:
		return false

	charges -= 1
	_state = STATE_ACTIVE
	_remaining = duration
	_time = 0.0
	health_component.invulnerable = true
	activate_sound.play()
	_emit_status()
	return true

func _process(delta: float) -> void:
	if _state != STATE_ACTIVE:
		return

	_time += delta
	_remaining -= delta
	_hit_flash = maxf(_hit_flash - delta * 3.0, 0.0)

	if _remaining <= 0.0:
		_remaining = 0.0
		health_component.invulnerable = false
		end_sound.play()
		_state = STATE_READY if charges > 0 else STATE_EMPTY

	_update_sprite()
	queue_redraw()
	_emit_status()

func _on_damage_blocked() -> void:
	_hit_flash = 1.0
	block_sound.play()

func _is_blinking_off() -> bool:
	return _remaining < warning_time and fmod(_time, 0.25) < 0.1

func _update_sprite() -> void:
	sprite.visible = shield_texture != null and _state == STATE_ACTIVE and not _is_blinking_off()
	sprite.modulate = Color.WHITE.lerp(Color(2.0, 2.0, 2.0), _hit_flash)

func _draw() -> void:
	# Bolha provisória enquanto não houver sprite.
	if shield_texture != null or _state != STATE_ACTIVE or _is_blinking_off():
		return

	var pulse: float = 0.5 + 0.5 * sin(_time * 6.0)
	var fill := Color(color, 0.12 + 0.06 * pulse + 0.3 * _hit_flash)
	var ring := Color(color.lightened(0.5), 0.7 + 0.3 * pulse)

	draw_circle(Vector2.ZERO, radius, fill)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 64, ring, 3.0, true)
	draw_arc(Vector2.ZERO, radius - 6.0, -2.4, -1.2, 16, Color(1, 1, 1, 0.35), 2.0, true)

func _emit_status() -> void:
	status_changed.emit(_state, _remaining, duration)
