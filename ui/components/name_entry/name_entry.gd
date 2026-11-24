extends Control

signal name_submitted(player_name: String)

const FONT_SIZE_NORMAL = 40
const FONT_SIZE_HOVER = 45

@onready var score_label = $ScoreLabel
@onready var name_input = $NameInput
@onready var submit_button = $SubmitButton
@onready var status_label = $StatusLabel
@onready var virtual_keyboard = $VirtualKeyboard


func _ready() -> void:
	visible = false

	configurar_botao(submit_button, "ENVIAR", "ENVIAR")
	submit_button.pressed.connect(_on_submit_pressed)
	name_input.text_submitted.connect(func(_text): _on_submit_pressed())

	virtual_keyboard.char_entered.connect(_on_virtual_char_entered)
	virtual_keyboard.backspace_pressed.connect(_on_virtual_backspace)
	virtual_keyboard.submit_requested.connect(_on_submit_pressed)
	InputDeviceManager.device_changed.connect(_on_device_changed)


func open(score: int) -> void:
	score_label.text = "PONTUAÇÃO: %d" % score
	status_label.text = ""
	submit_button.disabled = false
	name_input.text = ""
	visible = true
	_atualizar_modo_entrada()


## Com controle, o teclado da tela assume a digitação (o jogador não tem
## como digitar pelo teclado físico enquanto está no controle); no teclado
## físico, o campo de texto funciona normalmente.
func _atualizar_modo_entrada() -> void:
	var usando_controle = InputDeviceManager.using_gamepad
	virtual_keyboard.visible = usando_controle
	name_input.editable = not usando_controle

	if usando_controle:
		virtual_keyboard.focus_first_key()
	else:
		name_input.grab_focus()


func _on_device_changed(_using_gamepad: bool) -> void:
	if visible:
		_atualizar_modo_entrada()


func _on_virtual_char_entered(ch: String) -> void:
	if name_input.text.length() < name_input.max_length:
		name_input.text += ch


func _on_virtual_backspace() -> void:
	name_input.text = name_input.text.substr(0, name_input.text.length() - 1)


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
	# Controle: o botão selecionado pelo D-pad ganha o mesmo destaque do hover.
	botao.focus_entered.connect(_mouse_entrou.bind(botao, texto_hover))
	botao.focus_exited.connect(_mouse_saiu.bind(botao, texto_normal))


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
