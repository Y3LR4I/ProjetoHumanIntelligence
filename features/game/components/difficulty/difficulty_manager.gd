extends Node

signal dificuldade_alterada(nivel: int, config: Dictionary)

const NIVEIS = [
	{"velocidade": 35.0, "max_inimigos": 2, "intervalo_spawn": 4.0},
	{"velocidade": 45.0, "max_inimigos": 3, "intervalo_spawn": 3.5},
	{"velocidade": 58.0, "max_inimigos": 4, "intervalo_spawn": 3.0},
	{"velocidade": 72.0, "max_inimigos": 5, "intervalo_spawn": 2.5},
	{"velocidade": 90.0, "max_inimigos": 6, "intervalo_spawn": 2.0},
]

@export var duracao_por_nivel: float = 25.0

var nivel_atual: int = 1
var _tempo_no_nivel: float = 0.0

func _process(delta: float) -> void:
	if nivel_atual >= NIVEIS.size():
		return

	_tempo_no_nivel += delta

	if _tempo_no_nivel >= duracao_por_nivel:
		_tempo_no_nivel -= duracao_por_nivel
		nivel_atual += 1
		dificuldade_alterada.emit(nivel_atual, get_config())

func get_config() -> Dictionary:
	return NIVEIS[nivel_atual - 1]

func get_nivel_maximo() -> int:
	return NIVEIS.size()

func resetar() -> void:
	nivel_atual = 1
	_tempo_no_nivel = 0.0
	dificuldade_alterada.emit(nivel_atual, get_config())
