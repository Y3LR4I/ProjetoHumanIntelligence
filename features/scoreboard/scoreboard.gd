extends Control

const FADE_DURATION = 0.6

@onready var scoreboard_content = $ScoreboardContent
@onready var title = $ScoreboardContent/Title
@onready var terminal_text = $ScoreboardContent/TerminalText
@onready var ranking_header = $ScoreboardContent/RankingHeader
@onready var score_container = $ScoreboardContent/ScoreContainer
@onready var empty_label = $ScoreboardContent/EmptyLabel
@onready var back_button = $BackButton
@onready var background = $Background
@onready var fade_overlay = $FadeOverlay
@onready var click_sound = $ClickSound
@onready var terminal_sound = $ScoreSound

var scores_atuais: Array = []
var dados_recebidos = false
var terminal_concluido = false

const TERMINAL_LINES = [
	"> CONNECTING TO DATABASE...",
	"> RETRIEVING PLAYER RECORDS...",
	"> RANKING DATA LOADED."
]

func _ready() -> void:
	fade_overlay.visible = false

	# Elementos visíveis desde o início
	title.modulate.a = 1.0
	back_button.modulate.a = 1.0
	terminal_text.modulate.a = 1.0

	# Elementos que aparecem depois
	ranking_header.modulate.a = 0.0
	score_container.modulate.a = 0.0
	empty_label.modulate.a = 0.0
	
	back_button.mouse_entered.connect(_on_back_hover)

	back_button.text = "[ X ]"
	back_button.pressed.connect(_on_back_pressed)
	InputDeviceManager.focus_when_gamepad(back_button)

	ScoreboardManager.scores_received.connect(_on_scores_received)
	ScoreboardManager.get_top_scores(5)

	await get_tree().create_timer(0.5).timeout

	# Digita as mensagens do terminal
	await digitar_terminal()

	terminal_concluido = true

	# Faz o terminal desaparecer
	var tween = create_tween()
	tween.tween_property(terminal_text, "modulate:a", 0.0, 0.5)
	await tween.finished

	terminal_text.visible = false

	# Apresenta o ranking
	await aparecer_elemento(ranking_header)

	if dados_recebidos:
		await exibir_resultados()
		
func _on_back_hover():
	click_sound.play()
	
func digitar_terminal() -> void:
	terminal_text.text = ""

	for linha in TERMINAL_LINES:
		terminal_sound.play()

		for caractere in linha:
			terminal_text.text += caractere
			await get_tree().create_timer(0.035).timeout

		terminal_sound.stop()

		terminal_text.text += "\n"
		await get_tree().create_timer(0.4).timeout


func aparecer_elemento(elemento: CanvasItem) -> void:
	var tween = create_tween()
	tween.tween_property(elemento, "modulate:a", 1.0, FADE_DURATION)
	await tween.finished

func _on_scores_received(scores: Array) -> void:
	scores_atuais = scores
	dados_recebidos = true

	if terminal_concluido:
		await exibir_resultados()
		
func exibir_resultados() -> void:
	if scores_atuais.is_empty():
		empty_label.visible = true
		score_container.visible = false
		await aparecer_elemento(empty_label)
	else:
		empty_label.visible = false
		score_container.visible = true
		_popular_placar_com_dados_reais(scores_atuais)
		await aparecer_elemento(score_container)

func _popular_placar_com_dados_reais(scores: Array):
	for i in range(score_container.get_child_count()):
		score_container.get_child(i).queue_free()
	
	for i in range(scores.size()):
		var data = scores[i]
		var rank = i + 1
		var name = data.get("player_name", "Unknown")
		var score = data.get("score", 0)
		var entry = _criar_entrada_placar(rank, name, score)
		score_container.add_child(entry)


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
	rank_label.add_theme_color_override("font_color", Color("#39FF65"))
	container.add_child(rank_label)

	var name_label = Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 40)
	name_label.custom_minimum_size = Vector2(400, 70)
	name_label.horizontal_alignment = 0
	name_label.add_theme_color_override("font_color", Color("#39FF65"))
	container.add_child(name_label)

	var score_label = Label.new()
	score_label.text = "%d" % score
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.custom_minimum_size = Vector2(200, 70)
	score_label.horizontal_alignment = 2
	score_label.add_theme_color_override("font_color", Color("#39FF65"))
	container.add_child(score_label)

	return container

func _on_back_pressed():
	get_tree().change_scene_to_file("res://features/menu/menu.tscn")
