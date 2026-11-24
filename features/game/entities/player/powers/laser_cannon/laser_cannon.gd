extends Node2D

## Poder "Canhão Laser": dispara um feixe contínuo pra cima por `duration`
## segundos. A cada `tick_interval` todo inimigo dentro do feixe leva o
## `laser_damage` dele multiplicado por `damage_multiplier` (inimigos mais
## resistentes ao laser continuam mais resistentes ao feixe) e projéteis
## inimigos que tocarem no feixe são destruídos. Depois entra em recarga.

signal status_changed(state: StringName, remaining: float, total: float)

const STATE_READY: StringName = &"ready"
const STATE_ACTIVE: StringName = &"active"
const STATE_COOLDOWN: StringName = &"cooldown"

@export var duration: float = 5.0
@export var cooldown: float = 15.0
@export var tick_interval: float = 0.2
@export var damage_multiplier: float = 2.0
@export var beam_width: float = 34.0
## Y global onde o feixe termina (um pouco acima do topo da tela).
@export var beam_top_y: float = -20.0

@export_group("Sprites")
## Textura do feixe (repetida na vertical). Vazio = feixe provisório desenhado em código.
@export var beam_texture: Texture2D
## Textura do brilho na boca do canhão. Vazio = círculo provisório.
@export var muzzle_texture: Texture2D

@onready var beam_area: Area2D = $BeamArea
@onready var beam_shape: CollisionShape2D = $BeamArea/CollisionShape2D
@onready var glow_line: Line2D = $GlowLine
@onready var core_line: Line2D = $CoreLine
@onready var muzzle: Sprite2D = $Muzzle
@onready var start_sound: AudioStreamPlayer = $StartSound
@onready var loop_sound: AudioStreamPlayer = $LoopSound
@onready var end_sound: AudioStreamPlayer = $EndSound

var _state: StringName = STATE_READY
var _remaining: float = 0.0
var _tick_elapsed: float = 0.0

func _ready() -> void:
	beam_shape.shape = beam_shape.shape.duplicate()

	if beam_texture:
		core_line.texture = beam_texture
		core_line.texture_mode = Line2D.LINE_TEXTURE_TILE
		core_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		core_line.default_color = Color.WHITE
		glow_line.visible = false
	if muzzle_texture:
		muzzle.texture = muzzle_texture

	_update_beam_geometry()
	_set_beam_visible(false)
	_emit_status.call_deferred()

func is_active() -> bool:
	return _state == STATE_ACTIVE

func try_activate() -> bool:
	if _state != STATE_READY:
		return false

	_state = STATE_ACTIVE
	_remaining = duration
	_tick_elapsed = tick_interval
	_set_beam_visible(true)
	start_sound.play()
	loop_sound.play()
	_emit_status()
	return true

func _physics_process(delta: float) -> void:
	_update_beam_geometry()

	match _state:
		STATE_ACTIVE:
			_remaining -= delta
			_tick_elapsed += delta
			if _tick_elapsed >= tick_interval:
				_tick_elapsed -= tick_interval
				_damage_enemies()
			_destroy_enemy_projectiles()
			_animate_beam()

			if _remaining <= 0.0:
				_state = STATE_COOLDOWN
				_remaining = cooldown
				_set_beam_visible(false)
				loop_sound.stop()
				end_sound.play()
			_emit_status()
		STATE_COOLDOWN:
			_remaining -= delta
			if _remaining <= 0.0:
				_state = STATE_READY
				_remaining = 0.0
			_emit_status()

func _damage_enemies() -> void:
	for body in beam_area.get_overlapping_bodies():
		if body.is_in_group("player") or body.is_queued_for_deletion():
			continue
		if body.has_node("HealthComponent"):
			var health_component = body.get_node("HealthComponent")
			health_component.take_damage(health_component.laser_damage * damage_multiplier)

func _destroy_enemy_projectiles() -> void:
	for area in beam_area.get_overlapping_areas():
		if _is_enemy_projectile(area):
			area.queue_free()

func _is_enemy_projectile(area: Area2D) -> bool:
	return area.is_in_group("enemy_projectile")

func _update_beam_geometry() -> void:
	var length: float = maxf(global_position.y - beam_top_y, 0.0)
	var top := Vector2(0.0, -length)

	glow_line.points = PackedVector2Array([Vector2.ZERO, top])
	core_line.points = PackedVector2Array([Vector2.ZERO, top])

	var rect := beam_shape.shape as RectangleShape2D
	rect.size = Vector2(beam_width, length)
	beam_shape.position = Vector2(0.0, -length * 0.5)

func _animate_beam() -> void:
	glow_line.width = beam_width * 1.8 * randf_range(0.85, 1.1)
	core_line.width = (beam_width if beam_texture else beam_width * 0.45) * randf_range(0.9, 1.05)

func _set_beam_visible(value: bool) -> void:
	glow_line.visible = value and beam_texture == null
	core_line.visible = value
	muzzle.visible = value and muzzle_texture != null
	queue_redraw()

func _draw() -> void:
	# Brilho provisório na boca do canhão enquanto não houver sprite.
	if _state == STATE_ACTIVE and muzzle_texture == null:
		draw_circle(Vector2.ZERO, beam_width * 0.8, Color(0.6, 0.95, 1.0, 0.8))

func _emit_status() -> void:
	var total: float = duration if _state == STATE_ACTIVE else cooldown
	status_changed.emit(_state, maxf(_remaining, 0.0), total)
