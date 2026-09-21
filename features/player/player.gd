class_name Player
extends Area2D

signal vida_alterada(atual: float, maxima: float)
signal morreu
signal disparo_criado(projetil: Node2D)

const VIDA_MAXIMA: float = 7.0
const VELOCIDADE_MOVIMENTO: float = 320.0

const DANO_TIRO_LASER: float = 0.5
const INTERVALO_TIRO_LASER: float = 0.2

const DANO_RAJADA_LASER: float = 2.0
const COOLDOWN_RAJADA_LASER: float = 7.0

const COOLDOWN_RAJADA_FOTONICA: float = 180.0
const MARGEM_LIMITE_MOVIMENTO: float = 24.0
const ALCANCE_TIRO: float = 700.0

const PROJETIL_CENA: PackedScene = preload("res://features/projectile/projectile.tscn")

@onready var _timer_tiro_laser: Timer = $TimerTiroLaser
@onready var _timer_rajada_laser: Timer = $TimerRajadaLaser
@onready var _timer_rajada_fotonica: Timer = $TimerRajadaFotonica
@onready var _area_fotonica: Area2D = $PhotonicArea
@onready var _camera: Camera2D = $Camera2D

var vida_atual: float = VIDA_MAXIMA
var _pode_atirar_laser: bool = true
var _rajada_laser_pronta: bool = true
var _rajada_fotonica_pronta: bool = true
var _limites_movimento: Rect2 = Rect2(Vector2.ZERO, Vector2(1280, 720))
var _direcao_mira: Vector2 = Vector2.UP


func _ready() -> void:
	add_to_group("jogador")
	_timer_tiro_laser.wait_time = INTERVALO_TIRO_LASER
	_timer_rajada_laser.wait_time = COOLDOWN_RAJADA_LASER
	_timer_rajada_fotonica.wait_time = COOLDOWN_RAJADA_FOTONICA
	_timer_tiro_laser.timeout.connect(func(): _pode_atirar_laser = true)
	_timer_rajada_laser.timeout.connect(func(): _rajada_laser_pronta = true)
	_timer_rajada_fotonica.timeout.connect(func(): _rajada_fotonica_pronta = true)
	vida_alterada.emit(vida_atual, VIDA_MAXIMA)


func configurar_limites_movimento(area: Rect2) -> void:
	_limites_movimento = area.grow(-MARGEM_LIMITE_MOVIMENTO)


func configurar_limites_camera(area: Rect2) -> void:
	_camera.limit_left = int(area.position.x)
	_camera.limit_top = int(area.position.y)
	_camera.limit_right = int(area.end.x)
	_camera.limit_bottom = int(area.end.y)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_SPACE:
			_atirar_laser()
		KEY_SHIFT:
			_disparar_rajada_laser()
		KEY_CTRL:
			_usar_rajada_fotonica()


func _physics_process(delta: float) -> void:
	var direcao := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direcao != Vector2.ZERO:
		_direcao_mira = direcao
	position += direcao * VELOCIDADE_MOVIMENTO * delta
	position.x = clampf(position.x, _limites_movimento.position.x, _limites_movimento.end.x)
	position.y = clampf(position.y, _limites_movimento.position.y, _limites_movimento.end.y)


func sofrer_dano(quantidade: float) -> void:
	vida_atual = maxf(vida_atual - quantidade, 0.0)
	vida_alterada.emit(vida_atual, VIDA_MAXIMA)
	if vida_atual <= 0.0:
		morreu.emit()


func _atirar_laser() -> void:
	if not _pode_atirar_laser:
		return
	_pode_atirar_laser = false
	_timer_tiro_laser.start()
	_criar_projetil(DANO_TIRO_LASER)


func _disparar_rajada_laser() -> void:
	if not _rajada_laser_pronta:
		return
	_rajada_laser_pronta = false
	_timer_rajada_laser.start()
	_criar_projetil(DANO_RAJADA_LASER)


func _usar_rajada_fotonica() -> void:
	if not _rajada_fotonica_pronta:
		return
	_rajada_fotonica_pronta = false
	_timer_rajada_fotonica.start()
	for area in _area_fotonica.get_overlapping_areas():
		if area.is_in_group("inimigos") and area.has_method("destruir"):
			area.destruir()


func _criar_projetil(dano: float) -> void:
	var projetil: Area2D = PROJETIL_CENA.instantiate()
	projetil.position = position + _direcao_mira * 30.0
	projetil.collision_layer = 4
	projetil.collision_mask = 2
	projetil.configurar(_direcao_mira, dano, "inimigos", ALCANCE_TIRO)
	disparo_criado.emit(projetil)
