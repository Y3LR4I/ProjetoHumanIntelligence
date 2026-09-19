extends Control

@onready var background = $Background
@onready var play_button = $PlayButton
@onready var score_button = $ScoreButton
@onready var credits_button = $CreditsButton
@onready var exit_button = $ExitButton


func _ready():
	background.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 1.0, 2.5)
	
	configurar_botao(play_button, "JOGAR", "JOGAR")
	configurar_botao(score_button, "PLACAR", "PLACAR")
	configurar_botao(credits_button, "CREDITOS", "CREDITOS")
	configurar_botao(exit_button, "SAIR", "SAIR")


func configurar_botao(botao: Button, texto_normal: String, texto_hover: String):
	botao.text = texto_normal
	
	botao.mouse_entered.connect(_mouse_entrou.bind(botao, texto_hover))
	botao.mouse_exited.connect(_mouse_saiu.bind(botao, texto_normal))


func _mouse_entrou(botao: Button, texto: String):
	botao.text = texto
	
	var tween = create_tween()
	tween.tween_method(
		func(tamanho):
			botao.add_theme_font_size_override("font_size", tamanho),
		50,
		55,
		0.15
	)


func _mouse_saiu(botao: Button, texto: String):
	botao.text = texto
	
	var tween = create_tween()
	tween.tween_method(
		func(tamanho):
			botao.add_theme_font_size_override("font_size", tamanho),
		55,
		50,
		0.15
	)
