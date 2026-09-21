class_name LevelData
extends Resource

@export var nome_exibicao: String = ""
@export var area_jogavel: Rect2 = Rect2(Vector2.ZERO, Vector2(1920, 1080))
@export var posicao_inicial_jogador: Vector2 = Vector2(100, 540)
@export var posicao_porta: Vector2 = Vector2(1820, 540)
@export var inimigos: Array[EnemyPlacement] = []
@export var multiplicador_dificuldade: float = 1.0
