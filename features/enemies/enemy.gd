class_name Enemy
extends Area2D

enum Estado {
	PARADO,
	PERSEGUINDO,
}

signal destruido(pontos: int)
signal disparo_criado(projetil: Node2D)

const INTERVALO_DANO_CONTATO: float = 0.6

const PROJETIL_CENA: PackedScene = preload("res://features/projectile/projectile.tscn")
const LARGURA_BARRA_VIDA: float = 40.0

var dados: EnemyData
var vida_atual: float = 0.0

var _alvo: Player
var _estado: Estado = Estado.PARADO
var _dano_contato: float = 0.0
var _dano_distancia: float = 0.0
var _vida_maxima: float = 0.0

@onready var _timer_dano_contato: Timer = $ContactDamageTimer
@onready var _timer_ataque_distancia: Timer = $RangedAttackTimer
@onready var _notificador_tela: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var _barra_vida_preenchimento: ColorRect = $BarraVidaPreenchimento


func _ready() -> void:
	add_to_group("inimigos")
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	_timer_dano_contato.wait_time = INTERVALO_DANO_CONTATO
	_timer_dano_contato.timeout.connect(_aplicar_dano_contato)
	_notificador_tela.screen_entered.connect(_entrar_em_perseguicao)


func configurar(dados_inimigo: EnemyData, alvo: Player, multiplicador: float = 1.0) -> void:
	dados = dados_inimigo
	_alvo = alvo
	_vida_maxima = dados.max_health * multiplicador
	vida_atual = _vida_maxima
	_dano_contato = dados.contact_damage * multiplicador
	_dano_distancia = dados.ranged_damage * multiplicador

	var visual: ColorRect = $Visual
	visual.color = dados.color
	visual.size = dados.visual_size
	visual.position = -dados.visual_size / 2.0

	_atualizar_barra_vida()

	if dados.has_ranged_attack:
		_timer_ataque_distancia.wait_time = dados.ranged_interval
		_timer_ataque_distancia.timeout.connect(_disparar_ataque_distancia)


func _physics_process(delta: float) -> void:
	if dados == null or _alvo == null or _estado != Estado.PERSEGUINDO:
		return

	var direcao := position.direction_to(_alvo.position)
	position += direcao * dados.move_speed * delta


func _entrar_em_perseguicao() -> void:
	if dados == null or _estado == Estado.PERSEGUINDO:
		return
	_estado = Estado.PERSEGUINDO
	if dados.has_ranged_attack:
		_timer_ataque_distancia.start()


func sofrer_dano(quantidade: float) -> void:
	vida_atual -= quantidade
	_atualizar_barra_vida()
	if vida_atual <= 0.0:
		destruir()


func _atualizar_barra_vida() -> void:
	if _vida_maxima <= 0.0:
		return
	var proporcao := clampf(vida_atual / _vida_maxima, 0.0, 1.0)
	_barra_vida_preenchimento.size.x = LARGURA_BARRA_VIDA * proporcao


func destruir() -> void:
	destruido.emit(dados.points_value if dados else 0)
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("jogador"):
		return
	_aplicar_dano_contato()
	_timer_dano_contato.start()


func _on_area_exited(area: Area2D) -> void:
	if not area.is_in_group("jogador"):
		return
	_timer_dano_contato.stop()


func _aplicar_dano_contato() -> void:
	if _alvo != null and _alvo.has_method("sofrer_dano"):
		_alvo.sofrer_dano(_dano_contato)


func _disparar_ataque_distancia() -> void:
	if _alvo == null:
		return
	var projetil: Area2D = PROJETIL_CENA.instantiate()
	projetil.position = position
	projetil.collision_layer = 8
	projetil.collision_mask = 1
	projetil.configurar(position.direction_to(_alvo.position), _dano_distancia, "jogador")
	disparo_criado.emit(projetil)
