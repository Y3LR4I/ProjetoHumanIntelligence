extends Node

signal health_changed(health)
signal died
## Emitido quando um dano é ignorado por invulnerabilidade (ex: escudo).
signal damage_blocked

@export var max_health: float = 4.0
@export var laser_damage: float = 0.5

@export var player_damage_sound: AudioStream = preload("res://assets/audio/dano_player.wav")
@export var enemy_damage_sound: AudioStream = preload("res://assets/audio/dano_inimigo.wav")
@export var shake_strength: float = 4.0

const FLASH_COLOR := Color(1.0, 0.35, 0.35)

var health: float
var invulnerable: bool = false

@onready var _damage_sound_player: AudioStreamPlayer = $DamageSoundPlayer
@onready var _sprite: Node2D = get_parent().get_node_or_null("Sprite2D") as Node2D

var _sprite_rest_position: Vector2
var _flash_tween: Tween
var _shake_tween: Tween

func _ready():
	health = max_health
	if _sprite:
		_sprite_rest_position = _sprite.position

func take_damage(amount: float):
	# Já morto (dois acertos no mesmo frame): evita somar pontos duas vezes.
	if health <= 0:
		return
	if invulnerable:
		damage_blocked.emit()
		return

	health -= amount

	if get_parent().name == "player":
		print("Dano recebido: ", amount)
		print("Vida do Player: ", health, "/", max_health)

	health_changed.emit(health)
	_play_damage_feedback()

	if health <= 0:
		died.emit()

		var parent = get_parent()
		if parent.has_node("ScoreComponent"):
			ScoreManager.adicionar_pontos(parent.get_node("ScoreComponent").score)

		parent.queue_free()

func take_laser_hit() -> void:
	take_damage(laser_damage)

func can_receive_heal() -> bool:
	return health < max_health

func heal(amount: float) -> void:
	health = minf(health + amount, max_health)
	health_changed.emit(health)

func _play_damage_feedback() -> void:
	_play_damage_sound()
	_play_damage_flash()
	_play_damage_shake()

func _play_damage_sound() -> void:
	var sound := enemy_damage_sound if get_parent().is_in_group("inimigos") else player_damage_sound
	if not sound:
		return
	_damage_sound_player.stream = sound
	_damage_sound_player.play()

func _play_damage_flash() -> void:
	if not _sprite:
		return
	if _flash_tween:
		_flash_tween.kill()

	_sprite.self_modulate = FLASH_COLOR
	_flash_tween = create_tween()
	_flash_tween.tween_property(_sprite, "self_modulate", Color.WHITE, 0.18)

func _play_damage_shake() -> void:
	if not _sprite:
		return
	if _shake_tween:
		_shake_tween.kill()

	_sprite.position = _sprite_rest_position
	_shake_tween = create_tween()
	for i in range(3):
		var offset := Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
		_shake_tween.tween_property(_sprite, "position", _sprite_rest_position + offset, 0.03)
	_shake_tween.tween_property(_sprite, "position", _sprite_rest_position, 0.03)
