class_name HUD
extends CanvasLayer

@onready var _health_bar: HealthBar = $Margin/VBox/HealthBar
@onready var _score_label: Label = $Margin/VBox/ScoreLabel
@onready var _level_label: Label = $Margin/VBox/NivelLabel


func atualizar_vida(atual: float, maxima: float) -> void:
	_health_bar.atualizar(atual, maxima)


func atualizar_pontuacao(nova_pontuacao: int) -> void:
	_score_label.text = "PONTOS: %d" % nova_pontuacao


func atualizar_nivel(numero_nivel: int) -> void:
	_level_label.text = "FASE %d" % numero_nivel
