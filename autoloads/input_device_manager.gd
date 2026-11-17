extends Node

## Sabe se o jogador está usando teclado ou controle, pra UI mostrar os ícones
## certos e os menus poderem ser navegados pelo D-pad.
## - Conectar um controle (ex: PS4 via Bluetooth) já troca pra "controle".
## - Apertar botão/mexer analógico do controle -> "controle".
## - Apertar tecla ou clicar com o mouse -> "teclado".
## - Desconectar o último controle -> "teclado".

signal device_changed(using_gamepad: bool)

const STICK_THRESHOLD := 0.5

## Ícones dos botões do controle de PS4, pelo índice do botão no padrão SDL
## (o mesmo que o Godot usa: A = X/Cross, B = Bola, X = Quadrado, Y = Triângulo).
## Carregados sob demanda (load, não preload) pra não depender da ordem de
## importação quando o projeto é aberto pela primeira vez.
const GAMEPAD_GLYPHS := {
	JOY_BUTTON_A: "res://assets/textures/controle/ps4_cross.svg",
	JOY_BUTTON_B: "res://assets/textures/controle/ps4_circle.svg",
	JOY_BUTTON_X: "res://assets/textures/controle/ps4_square.svg",
	JOY_BUTTON_Y: "res://assets/textures/controle/ps4_triangle.svg",
}

var using_gamepad: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	using_gamepad = not Input.get_connected_joypads().is_empty()
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		_set_using_gamepad(true)
	elif event is InputEventJoypadMotion and absf(event.axis_value) > STICK_THRESHOLD:
		_set_using_gamepad(true)
	elif (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
		_set_using_gamepad(false)

## Ícone do botão do controle ligado à ação (o 1º botão de controle do InputMap).
func glyph_for_action(action: StringName) -> Texture2D:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and GAMEPAD_GLYPHS.has(event.button_index):
			return load(GAMEPAD_GLYPHS[event.button_index])
	return null

## Pros menus: com controle, `control` já vem selecionado pra navegar pelo D-pad.
## Se o jogador trocar pro controle com a tela aberta e nada focado, foca nele.
func focus_when_gamepad(control: Control) -> void:
	var callback := _grab_focus_if_needed.bind(control)
	device_changed.connect(callback)
	control.tree_exiting.connect(func() -> void:
		if device_changed.is_connected(callback):
			device_changed.disconnect(callback), CONNECT_ONE_SHOT)
	if using_gamepad:
		_grab_focus_if_needed.call_deferred(true, control)

func _grab_focus_if_needed(gamepad: bool, control: Control) -> void:
	if not gamepad or not is_instance_valid(control) or not control.is_visible_in_tree():
		return
	if control.get_viewport().gui_get_focus_owner() == null:
		control.grab_focus()

func _set_using_gamepad(value: bool) -> void:
	if value == using_gamepad:
		return
	using_gamepad = value
	device_changed.emit(value)

func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	if connected:
		_set_using_gamepad(true)
	elif Input.get_connected_joypads().is_empty():
		_set_using_gamepad(false)
