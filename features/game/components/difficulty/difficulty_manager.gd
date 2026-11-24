extends Node

signal dificuldade_alterada(nivel: int, config: Dictionary)

const NIVEIS := [
	{"pontos": 0, "velocidade": 35.0, "max_inimigos": 2, "intervalo_spawn": 4.0, "intervalo_tiro_mult": 1.0, "velocidade_projetil_mult": 1.0, "cura_valor": 2.0, "chance_escudo": 0.18, "intervalo_escudo": 18.0, "garantia_escudo": 30.0},
	{"pontos": 600, "velocidade": 45.0, "max_inimigos": 3, "intervalo_spawn": 3.4, "intervalo_tiro_mult": 0.95, "velocidade_projetil_mult": 1.05, "cura_valor": 2.0, "chance_escudo": 0.15, "intervalo_escudo": 22.0, "garantia_escudo": 35.0},
	{"pontos": 1400, "velocidade": 55.0, "max_inimigos": 4, "intervalo_spawn": 2.9, "intervalo_tiro_mult": 0.85, "velocidade_projetil_mult": 1.1, "cura_valor": 2.0, "chance_escudo": 0.12, "intervalo_escudo": 28.0, "garantia_escudo": 42.0},
	{"pontos": 2600, "velocidade": 65.0, "max_inimigos": 4, "intervalo_spawn": 2.5, "intervalo_tiro_mult": 0.75, "velocidade_projetil_mult": 1.18, "cura_valor": 1.0, "chance_escudo": 0.10, "intervalo_escudo": 34.0, "garantia_escudo": 50.0},
	{"pontos": 4200, "velocidade": 75.0, "max_inimigos": 5, "intervalo_spawn": 2.1, "intervalo_tiro_mult": 0.68, "velocidade_projetil_mult": 1.25, "cura_valor": 1.0, "chance_escudo": 0.08, "intervalo_escudo": 40.0, "garantia_escudo": 58.0},
	{"pontos": 6200, "velocidade": 85.0, "max_inimigos": 6, "intervalo_spawn": 1.8, "intervalo_tiro_mult": 0.6, "velocidade_projetil_mult": 1.32, "cura_valor": 1.0, "chance_escudo": 0.07, "intervalo_escudo": 46.0, "garantia_escudo": 66.0},
	{"pontos": 8800, "velocidade": 95.0, "max_inimigos": 6, "intervalo_spawn": 1.55, "intervalo_tiro_mult": 0.52, "velocidade_projetil_mult": 1.38, "cura_valor": 1.0, "chance_escudo": 0.06, "intervalo_escudo": 52.0, "garantia_escudo": 74.0},
	{"pontos": 12000, "velocidade": 108.0, "max_inimigos": 7, "intervalo_spawn": 1.3, "intervalo_tiro_mult": 0.45, "velocidade_projetil_mult": 1.45, "cura_valor": 1.0, "chance_escudo": 0.05, "intervalo_escudo": 58.0, "garantia_escudo": 82.0},
]

const PONTOS_POR_FAIXA_EXTRA := 3000.0
const VELOCIDADE_MAXIMA := 160.0
const INTERVALO_TIRO_MULT_MINIMO := 0.3
const INTERVALO_SPAWN_MINIMO := 0.9
const VELOCIDADE_PROJETIL_MULT_MAXIMO := 1.8

var nivel_atual: int = 1

func _ready() -> void:
	ScoreManager.score_changed.connect(_on_score_changed)

func _on_score_changed(score: int) -> void:
	var novo_nivel := _calcular_nivel(score)
	if novo_nivel != nivel_atual:
		nivel_atual = novo_nivel
		dificuldade_alterada.emit(nivel_atual, get_config())

func _calcular_nivel(score: int) -> int:
	var nivel := 1
	for i in range(NIVEIS.size()):
		if score >= NIVEIS[i]["pontos"]:
			nivel = i + 1
	return nivel

func get_config() -> Dictionary:
	return _config_para_pontos(ScoreManager.score)

func _config_para_pontos(score: int) -> Dictionary:
	var config: Dictionary = NIVEIS[nivel_atual - 1].duplicate()

	if nivel_atual == NIVEIS.size():
		var pontos_extra: float = maxf(0.0, score - config["pontos"])
		var faixas: float = floor(pontos_extra / PONTOS_POR_FAIXA_EXTRA)
		config["velocidade"] = minf(config["velocidade"] + faixas * 8.0, VELOCIDADE_MAXIMA)
		config["intervalo_tiro_mult"] = maxf(config["intervalo_tiro_mult"] - faixas * 0.03, INTERVALO_TIRO_MULT_MINIMO)
		config["intervalo_spawn"] = maxf(config["intervalo_spawn"] - faixas * 0.05, INTERVALO_SPAWN_MINIMO)
		config["velocidade_projetil_mult"] = minf(config["velocidade_projetil_mult"] + faixas * 0.03, VELOCIDADE_PROJETIL_MULT_MAXIMO)

	return config

func get_nivel_maximo() -> int:
	return NIVEIS.size()

func resetar() -> void:
	nivel_atual = 1
	dificuldade_alterada.emit(nivel_atual, get_config())
