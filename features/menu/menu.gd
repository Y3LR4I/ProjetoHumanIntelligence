extends Control

const FONT_SIZE_NORMAL = 50
const FONT_SIZE_HOVER = 55
const FADE_IN_DURATION = 2.5

@onready var background = $Background
@onready var game_title = $GameTitle
@onready var play_button = $PlayButton
@onready var score_button = $ScoreButton
@onready var credits_button = $CreditsButton
@onready var exit_button = $ExitButton
@onready var menu_music = $MenuMusic
@onready var hover_sound = $HoverSound
@onready var glitch_overlay = $GlitchOverlay


func _ready():
	_animar_entrada()

	configurar_botao(play_button, "JOGAR", "JOGAR")
	configurar_botao(score_button, "PLACAR", "PLACAR")
	configurar_botao(credits_button, "CREDITOS", "CREDITOS")
	configurar_botao(exit_button, "SAIR", "SAIR")

	play_button.pressed.connect(_on_play_pressed)
	score_button.pressed.connect(_on_score_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	menu_music.stream.loop = true
	menu_music.play()
	
	credits_button.pressed.connect(_on_credits_pressed)
	glitch_overlay.visible = false


func _animar_entrada():
	var elementos = [background, game_title, play_button, score_button, credits_button, exit_button]

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
	hover_sound.play()


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

func _on_play_pressed():
	menu_music.stop()
	get_tree().change_scene_to_file("res://features/game/game.tscn")

func _on_score_pressed():
	print("Score button pressed, going to scoreboard")
	if ResourceLoader.exists("res://features/scoreboard/scoreboard.tscn"):
		print("Scene file exists, changing scene...")
		get_tree().change_scene_to_file("res://features/scoreboard/scoreboard.tscn")
	else:
		print("ERROR: Scene file not found!")
		push_error("Scoreboard scene not found at res://features/scoreboard/scoreboard.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://features/credits/credits.tscn")

func _on_exit_pressed():
	get_tree().quit()
	
func _on_credits_pressed():
	credits_button.disabled = true
	glitch_overlay.visible = true
	glitch_overlay.modulate.a = 0.0

	var tween = create_tween()

	# Primeiro flash
	tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.05)
	tween.tween_interval(0.04)

	# Interrupção
	tween.tween_property(glitch_overlay, "modulate:a", 0.0, 0.04)
	tween.tween_interval(0.06)

	# Segundo flash
	tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.03)
	tween.tween_interval(0.08)

	# Tela preta
	tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.1)

	await tween.finished

	menu_music.stop()
	get_tree().change_scene_to_file("res://features/credits/credits.tscn")
