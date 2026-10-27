extends Control

signal name_submitted(player_name: String)

const FONT_SIZE_NORMAL = 40
const FONT_SIZE_HOVER = 45

@onready var score_label = $ScoreLabel
@onready var name_input = $NameInput
@onready var submit_button = $SubmitButton
@onready var status_label = $StatusLabel


func _ready() -> void:
	visible = false

	configurar_botao(submit_button, "ENVIAR", "ENVIAR")
	submit_button.pressed.connect(_on_submit_pressed)
	name_input.text_submitted.connect(func(_text): _on_submit_pressed())


func open(score: int) -> void:
	score_label.text = "PONTUAÇÃO: %d" % score
	status_label.text = ""
	submit_button.disabled = false
	name_input.text = ""
	visible = true
	name_input.grab_focus()


func set_status(text: String) -> void:
	status_label.text = text
	submit_button.disabled = false


func _on_submit_pressed() -> void:
	var player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = "Jogador"

	submit_button.disabled = true
	status_label.text = "Enviando..."
	name_submitted.emit(player_name)


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
