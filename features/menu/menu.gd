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


func _ready():
	_animar_entrada()

	configurar_botao(play_button, "JOGAR", "JOGAR")
	configurar_botao(score_button, "PLACAR", "PLACAR")
	configurar_botao(credits_button, "CREDITOS", "CREDITOS")
	configurar_botao(exit_button, "SAIR", "SAIR")

	play_button.pressed.connect(_on_play_button_pressed)


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


func _on_play_button_pressed():
	SceneManager.ir_para_jogo()
