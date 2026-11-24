extends Control

## Teclado na tela pra digitar o nome com o controle (D-pad move entre as
## teclas, ui_accept confirma a tecla selecionada). Monta as teclas em
## código pra não precisar de ~30 nós de botão escritos à mão na cena.

signal char_entered(ch: String)
signal backspace_pressed
signal submit_requested

const LETTER_ROWS := ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]
const KEY_SIZE := Vector2(70, 50)
const KEY_SEPARATION := 8
const ACTION_KEY_SEPARATION := 20
const FONT_SIZE := 28

@export var font: Font

@onready var rows_container: VBoxContainer = $Rows

var _first_key: Button

func _ready() -> void:
	rows_container.alignment = BoxContainer.ALIGNMENT_CENTER

	for letters in LETTER_ROWS:
		_build_letter_row(letters)
	_build_action_row()

func focus_first_key() -> void:
	if _first_key:
		_first_key.grab_focus()

func _build_letter_row(letters: String) -> void:
	var row := _criar_linha(KEY_SEPARATION)

	for letter in letters:
		var key := _criar_tecla(letter, KEY_SIZE)
		key.pressed.connect(func(): char_entered.emit(letter))
		row.add_child(key)
		if _first_key == null:
			_first_key = key

func _build_action_row() -> void:
	var row := _criar_linha(ACTION_KEY_SEPARATION)

	var space_key := _criar_tecla("ESPAÇO", Vector2(220, 50))
	space_key.pressed.connect(func(): char_entered.emit(" "))
	row.add_child(space_key)

	var del_key := _criar_tecla("DEL", Vector2(140, 50))
	del_key.pressed.connect(func(): backspace_pressed.emit())
	row.add_child(del_key)

	var ok_key := _criar_tecla("OK", Vector2(140, 50))
	ok_key.pressed.connect(func(): submit_requested.emit())
	row.add_child(ok_key)

func _criar_linha(separation: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", separation)
	rows_container.add_child(row)
	return row

func _criar_tecla(texto: String, tamanho: Vector2) -> Button:
	var botao := Button.new()
	botao.text = texto
	botao.custom_minimum_size = tamanho
	botao.focus_mode = Control.FOCUS_ALL
	if font:
		botao.add_theme_font_override("font", font)
	botao.add_theme_font_size_override("font_size", FONT_SIZE)
	return botao
