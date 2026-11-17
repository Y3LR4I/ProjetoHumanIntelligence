extends Node

signal dificuldade_alterada(nivel: int, config: Dictionary)

# Drop do escudo por nível (quanto mais difícil, mais frequente):
#   chance_escudo   -> chance de dropar a cada robô destruído
#   intervalo_escudo -> tempo mínimo (s) entre um drop e outro
#   garantia_escudo  -> depois desse tempo (s) sem drop, o próximo robô dropa com certeza
const NIVEIS = [
	{"velocidade": 35.0, "max_inimigos": 2, "intervalo_spawn": 4.0, "chance_escudo": 0.08, "intervalo_escudo": 40.0, "garantia_escudo": 75.0},
	{"velocidade": 45.0, "max_inimigos": 3, "intervalo_spawn": 3.5, "chance_escudo": 0.10, "intervalo_escudo": 35.0, "garantia_escudo": 65.0},
	{"velocidade": 58.0, "max_inimigos": 4, "intervalo_spawn": 3.0, "chance_escudo": 0.13, "intervalo_escudo": 30.0, "garantia_escudo": 55.0},
	{"velocidade": 72.0, "max_inimigos": 5, "intervalo_spawn": 2.5, "chance_escudo": 0.16, "intervalo_escudo": 25.0, "garantia_escudo": 45.0},
	{"velocidade": 90.0, "max_inimigos": 6, "intervalo_spawn": 2.0, "chance_escudo": 0.20, "intervalo_escudo": 20.0, "garantia_escudo": 35.0},
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
