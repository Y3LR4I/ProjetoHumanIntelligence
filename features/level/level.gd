class_name Level
extends Node2D

signal nivel_concluido
signal disparo_criado(projetil: Node2D)
signal pontos_ganhos(pontos: int)

const ENEMY_CENA: PackedScene = preload("res://features/enemies/enemy.tscn")

@onready var _door: Area2D = $Door
@onready var _inimigos: Node2D = $Inimigos
@onready var _chao: ColorRect = $Chao


func _ready() -> void:
	_door.area_entered.connect(_on_door_area_entered)


func configurar(dados: LevelData, jogador: Player) -> void:
	jogador.position = dados.posicao_inicial_jogador
	jogador.configurar_limites_movimento(dados.area_jogavel)
	jogador.configurar_limites_camera(dados.area_jogavel)

	_chao.position = dados.area_jogavel.position
	_chao.size = dados.area_jogavel.size

	_door.position = dados.posicao_porta

	for colocacao in dados.inimigos:
		var inimigo: Area2D = ENEMY_CENA.instantiate()
		_inimigos.add_child(inimigo)
		inimigo.position = colocacao.posicao
		inimigo.configurar(colocacao.dados, jogador, dados.multiplicador_dificuldade)
		inimigo.destruido.connect(_on_inimigo_destruido)
		inimigo.disparo_criado.connect(_on_disparo_criado)


func _on_door_area_entered(area: Area2D) -> void:
	if area.is_in_group("jogador"):
		nivel_concluido.emit()


func _on_inimigo_destruido(pontos: int) -> void:
	pontos_ganhos.emit(pontos)


func _on_disparo_criado(projetil: Node2D) -> void:
	disparo_criado.emit(projetil)
