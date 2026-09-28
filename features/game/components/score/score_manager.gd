extends Node

var score: int = 0

func adicionar_pontos(pontos: int) -> void:
	score += pontos
	print("Score: ", score)

func resetar_score() -> void:
	score = 0
