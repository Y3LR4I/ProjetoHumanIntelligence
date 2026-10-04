extends Control

const FONT_SIZE_NORMAL = 50
const FONT_SIZE_HOVER = 55
const FADE_IN_DURATION = 1.5

@onready var score_container = $ScoreContainer
@onready var back_button = $BackButton
@onready var title = $Title
@onready var background = $Background
@onready var fade_overlay = $FadeOverlay

var mock_scores = [
	{ "rank": 1, "name": "PlayerOne", "score": 9850 },
	{ "rank": 2, "name": "GameMaster", "score": 8720 },
	{ "rank": 3, "name": "SpeedRunner", "score": 7650 },
	{ "rank": 4, "name": "ProGamer", "score": 6540 },
	{ "rank": 5, "name": "Newbie", "score": 5430 },
]

func _ready():
	_popular_placar()
	_animar_entrada()
	configurar_botao(back_button, "VOLTAR", "VOLTAR")
	back_button.pressed.connect(_on_back_pressed)
	print("Scoreboard ready, back button connected")

func _popular_placar():
	for i in range(score_container.get_child_count()):
		score_container.get_child(i).queue_free()

	for data in mock_scores:
		var entry = _criar_entrada_placar(data.rank, data.name, data.score)
		score_container.add_child(entry)
	print("Placar populado com %d entradas" % mock_scores.size())

func _criar_entrada_placar(rank: int, name: String, score: int) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.alignment = 1
	container.add_theme_constant_override("separation", 40)
	container.custom_minimum_size = Vector2(0, 70)

	var rank_label = Label.new()
	rank_label.text = "#%d" % rank
	rank_label.add_theme_font_size_override("font_size", 40)
	rank_label.custom_minimum_size = Vector2(80, 70)
	rank_label.horizontal_alignment = 1
	rank_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(rank_label)

	var name_label = Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 40)
	name_label.custom_minimum_size = Vector2(400, 70)
	name_label.horizontal_alignment = 0
	name_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(name_label)

	var score_label = Label.new()
	score_label.text = "%d" % score
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.custom_minimum_size = Vector2(200, 70)
	score_label.horizontal_alignment = 2
	score_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(score_label)

	return container

func _animar_entrada():
	var elementos = [background, fade_overlay, title, score_container, back_button]

	for elemento in elementos:
		elemento.modulate.a = 0.0

	var tween = create_tween()
	tween.set_parallel(true)

	for elemento in elementos:
		tween.tween_property(elemento, "modulate:a", 1.0, FADE_IN_DURATION)

func configurar_botao(botao: Button, texto_normal: String, texto_hover: String):
	botao.text = texto_normal

	botao.mouse_entered.connect(_mouse_entrou.bind(botao, texto_hover))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao, texto_normal))

func _mouse_entrou(botao: Button, texto: String):
	botao.text = texto
	_animar_tamanho_fonte(botao, FONT_SIZE_NORMAL, FONT_SIZE_HOVER)

func _mouse_saiu(botao: Button, texto: String):
	botao.text = texto
	_animar_tamanho_fonte(botao, FONT_SIZE_HOVER, FONT_SIZE_NORMAL)

func _animar_tamanho_fonte(botao: Button, de: int, para: int):
	var tween = create_tween()
	tween.tween_method(
		func(tamanho):
			botao.add_theme_font_size_override("font_size", tamanho),
		de,
		para,
		0.15
	)

func _on_back_pressed():
	print("Back button pressed, returning to menu")
	get_tree().change_scene_to_file("res://features/menu/menu.tscn")