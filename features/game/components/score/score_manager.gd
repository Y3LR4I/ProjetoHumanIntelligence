extends Node

signal score_changed(score)

var score: int = 0

func adicionar_pontos(pontos: int) -> void:
	score += pontos
	score_changed.emit(score)

func resetar_score() -> void:
	score = 0
	score_changed.emit(score)
