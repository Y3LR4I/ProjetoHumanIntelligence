extends CharacterBody2D

## Drone voador: entra no topo, fica pairando e dispara mísseis teleguiados
## no player. Antes de cada disparo o drone pisca em rosa (aviso) pra dar
## tempo de reagir. Quando o tempo de patrulha acaba, para de atirar e desce.

@export var missile_scene: PackedScene
## Sprites por estágio de dano (0 = intacto). As texturas têm tamanhos
## diferentes, por isso cada uma tem a sua própria escala.
@export var health_sprites: Array[Texture2D]
@export var health_sprite_scales: Array[float]
@export var telegraph_time: float = 0.45
## Multiplicador do intervalo de tiro no último estágio de dano (atira mais devagar).
@export var critical_fire_interval_multiplier: float = 1.5
## Velocidade vinda do DifficultyManager (80 = velocidade de referência).
@export var velocidade_base: float = 80.0

const TELEGRAPH_COLOR := Color(1.0, 0.45, 0.9)
const VELOCIDADE_REFERENCIA := 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_component = $HealthComponent
@onready var hover_movement = $HoverMovement
@onready var shoot_timer: Timer = $ShootTimer
@onready var missile_spawn: Marker2D = $MissileSpawn

var _stage: int = -1
var _dying: bool = false
var _entry_speed_base: float
var _exit_speed_base: float
var _shoot_interval_base: float
var _intervalo_tiro_mult: float = 1.0
var _velocidade_projetil_mult: float = 1.0

func _ready() -> void:
	add_to_group("inimigos")
	_entry_speed_base = hover_movement.entry_speed
	_exit_speed_base = hover_movement.exit_speed
	_shoot_interval_base = shoot_timer.wait_time
	_aplicar_velocidade()
	health_component.health_changed.connect(_on_health_changed)
	hover_movement.hover_started.connect(_on_hover_started)
	hover_movement.hover_finished.connect(_on_hover_finished)
	_set_stage(0)

## Chamado pelo EnemySpawner quando o nível de dificuldade muda.
func configurar_dificuldade(config: Dictionary) -> void:
	velocidade_base = config.get("velocidade", velocidade_base)
	_intervalo_tiro_mult = config.get("intervalo_tiro_mult", 1.0)
	_velocidade_projetil_mult = config.get("velocidade_projetil_mult", 1.0)
	_aplicar_velocidade()
	_aplicar_intervalo_tiro()

func _aplicar_velocidade() -> void:
	var fator: float = velocidade_base / VELOCIDADE_REFERENCIA
	hover_movement.entry_speed = _entry_speed_base * fator
	hover_movement.exit_speed = _exit_speed_base * fator

func _aplicar_intervalo_tiro() -> void:
	var mult := _intervalo_tiro_mult
	if _stage == health_sprites.size() - 1:
		mult *= critical_fire_interval_multiplier
	shoot_timer.wait_time = _shoot_interval_base * mult

func _on_hover_started() -> void:
	shoot_timer.start()

func _on_hover_finished() -> void:
	shoot_timer.stop()

func _on_shoot_timer_timeout() -> void:
	if _dying:
		return

	var tween := create_tween()
	tween.tween_property(sprite, "modulate", TELEGRAPH_COLOR, telegraph_time * 0.5)
	tween.tween_property(sprite, "modulate", Color.WHITE, telegraph_time * 0.5)
	tween.tween_callback(_launch_missile)

func _launch_missile() -> void:
	if _dying or not hover_movement.is_hovering():
		return

	var missile = missile_scene.instantiate()
	missile.speed *= _velocidade_projetil_mult
	missile.global_position = missile_spawn.global_position

	var target := get_tree().get_first_node_in_group("player") as Node2D
	if target:
		missile.target = target
		missile.direction = (target.global_position - missile_spawn.global_position).normalized()

	get_tree().current_scene.add_child(missile)

func _on_health_changed(health: float) -> void:
	var ratio: float = clampf(health / health_component.max_health, 0.0, 1.0)
	var stage: int = clampi(int((1.0 - ratio) * health_sprites.size()), 0, health_sprites.size() - 1)
	_set_stage(stage)

func _set_stage(stage: int) -> void:
	if stage == _stage:
		return

	_stage = stage
	sprite.texture = health_sprites[stage]
	if stage < health_sprite_scales.size():
		sprite.scale = Vector2.ONE * health_sprite_scales[stage]

	_aplicar_intervalo_tiro()

func destruir_na_borda() -> void:
	_dying = true
	shoot_timer.stop()
	await get_tree().create_timer(0.3).timeout

	_set_stage(health_sprites.size() - 2)

	await get_tree().create_timer(0.2).timeout

	_set_stage(health_sprites.size() - 1)

	await get_tree().create_timer(0.2).timeout

	queue_free()
