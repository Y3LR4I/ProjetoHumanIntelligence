extends Node2D

## Placeholder: sem tela de game over/placar ainda (fora do escopo desta rodada).
## Ao "perder", o jogo só pausa — RF45-47 (mostrar pontuação, salvar placar)
## ficam para quando a tela de resultado existir.

const LEVEL_CENA: PackedScene = preload("res://features/level/level.tscn")

const NIVEIS: Array[LevelData] = [
	preload("res://resources/levels/nivel_01.tres"),
	preload("res://resources/levels/nivel_02.tres"),
	preload("res://resources/levels/nivel_03.tres"),
]

@onready var _player: Player = $Player
@onready var _projectiles: Node2D = $Projectiles
@onready var _hud: HUD = $HUD
@onready var _level_container: Node2D = $LevelContainer

var _nivel_atual_idx: int = 0
var _nivel_atual: Level
var _partida_finalizada: bool = false


func _ready() -> void:
	GameManager.reiniciar_estado()

	_player.vida_alterada.connect(_hud.atualizar_vida)
	_player.morreu.connect(_finalizar_partida)
	_player.disparo_criado.connect(_on_disparo_criado)

	GameManager.pontuacao_alterada.connect(_hud.atualizar_pontuacao)

	_hud.atualizar_vida(_player.vida_atual, Player.VIDA_MAXIMA)
	_hud.atualizar_pontuacao(GameManager.pontuacao)

	_carregar_nivel(0)


func _carregar_nivel(indice: int) -> void:
	_nivel_atual_idx = indice
	_hud.atualizar_nivel(_nivel_atual_idx + 1)

	_nivel_atual = LEVEL_CENA.instantiate()
	_level_container.add_child(_nivel_atual)
	_nivel_atual.configurar(NIVEIS[_nivel_atual_idx], _player)
	_nivel_atual.nivel_concluido.connect(_on_nivel_concluido)
	_nivel_atual.disparo_criado.connect(_on_disparo_criado)
	_nivel_atual.pontos_ganhos.connect(_on_pontos_ganhos)


func _on_pontos_ganhos(pontos: int) -> void:
	GameManager.adicionar_pontuacao(pontos)


func _on_disparo_criado(projetil: Node2D) -> void:
	_projectiles.add_child(projetil)


func _on_nivel_concluido() -> void:
	_nivel_atual.queue_free()
	_carregar_nivel((_nivel_atual_idx + 1) % NIVEIS.size())


func _finalizar_partida() -> void:
	if _partida_finalizada:
		return
	_partida_finalizada = true
	GameManager.registrar_fim_de_partida(_player.vida_atual)
	get_tree().paused = true
