extends Control

## Slot de poder redondo no HUD. Só apresentação: recebe o estado do poder via
## update_status() e mostra ícone, tecla de ativação (ou o botão do controle,
## quando o jogador está usando um), tempo ativo (anel em
## volta do botão) e recarga (varredura radial escura + contagem em segundos).

@export var power_name: String = "CANHAO LASER"
## Ação do InputMap que ativa o poder — a tecla mostrada no slot vem dela.
@export var input_action: StringName = &"power_laser_cannon"
## Sprite do ícone do poder. Vazio = mostra `placeholder_text` no lugar.
@export var icon: Texture2D
@export var placeholder_text: String = "LC"
@export var ready_color: Color = Color(0.3, 0.85, 1.0)
@export var active_color: Color = Color(1.0, 1.0, 1.0)
@export var cooldown_color: Color = Color(0.35, 0.35, 0.4)
@export var cooldown_shade: Color = Color(0.0, 0.0, 0.0, 0.65)
@export var ring_width: float = 4.0

@onready var name_label: Label = $NameLabel
@onready var frame: Panel = $Frame
@onready var icon_rect: TextureRect = $Frame/Icon
@onready var placeholder_label: Label = $Frame/PlaceholderLabel
@onready var indicator: Control = $Frame/Indicator
@onready var cooldown_label: Label = $Frame/CooldownLabel
@onready var key_badge: Panel = $KeyBadge
@onready var key_label: Label = $KeyBadge/KeyLabel
@onready var key_icon: TextureRect = $KeyBadge/KeyIcon

var _style: StyleBoxFlat
var _last_state: StringName = &""
var _state: StringName = &"ready"
var _ratio: float = 0.0

func _ready() -> void:
	name_label.text = power_name
	_refresh_key()
	InputDeviceManager.device_changed.connect(func(_gamepad: bool) -> void: _refresh_key())
	icon_rect.texture = icon
	placeholder_label.text = placeholder_text
	placeholder_label.visible = icon == null

	_style = (frame.get_theme_stylebox("panel") as StyleBoxFlat).duplicate()
	frame.add_theme_stylebox_override("panel", _style)
	frame.pivot_offset = frame.size * 0.5
	indicator.draw.connect(_draw_indicator)

	update_status(&"ready", 0.0, 1.0)

func update_status(state: StringName, remaining: float, total: float) -> void:
	_state = state
	_ratio = clampf(remaining / total, 0.0, 1.0) if total > 0.0 else 0.0

	match state:
		&"active":
			_style.border_color = active_color
			cooldown_label.visible = false
			_set_content_modulate(Color.WHITE)
		&"cooldown":
			_style.border_color = cooldown_color
			cooldown_label.visible = true
			cooldown_label.text = str(ceili(remaining))
			_set_content_modulate(Color(0.5, 0.5, 0.55))
		&"blocked", &"empty":
			# Indisponível sem contagem: bloqueado (ex: tiro durante o canhão laser)
			# ou sem carga (ex: escudo antes de pegar o upgrade).
			_style.border_color = cooldown_color
			cooldown_label.visible = false
			_set_content_modulate(Color(0.5, 0.5, 0.55))
		_:
			_style.border_color = ready_color
			cooldown_label.visible = false
			_set_content_modulate(Color.WHITE)
			if _last_state in [&"cooldown", &"blocked", &"empty"]:
				_flash_ready()

	_last_state = state
	indicator.queue_redraw()

## Feedback rápido de uso (ex: a cada tiro disparado).
func pulse() -> void:
	frame.scale = Vector2(0.88, 0.88)
	var tween := create_tween()
	tween.tween_property(frame, "scale", Vector2.ONE, 0.12)

func _draw_indicator() -> void:
	var center: Vector2 = indicator.size * 0.5
	var radius: float = minf(center.x, center.y)
	var start: float = -PI * 0.5  # começa no topo, sentido horário

	match _state:
		&"cooldown":
			_draw_pie(center, radius - 2.0, start, start + TAU * _ratio, cooldown_shade)
		&"blocked", &"empty":
			indicator.draw_circle(center, radius - 2.0, cooldown_shade)
		&"active":
			indicator.draw_arc(center, radius - ring_width * 0.5, start, start + TAU * _ratio, 64, ready_color, ring_width, true)

func _draw_pie(center: Vector2, radius: float, from_angle: float, to_angle: float, color: Color) -> void:
	if to_angle - from_angle <= 0.001:
		return
	var points := PackedVector2Array([center])
	var segments: int = maxi(3, int(48.0 * (to_angle - from_angle) / TAU))
	for i in segments + 1:
		var angle: float = lerpf(from_angle, to_angle, float(i) / segments)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	indicator.draw_colored_polygon(points, color)

func _set_content_modulate(color: Color) -> void:
	icon_rect.modulate = color
	placeholder_label.modulate = color

func _flash_ready() -> void:
	frame.modulate = Color(2.0, 2.0, 2.0)
	var tween := create_tween()
	tween.tween_property(frame, "modulate", Color.WHITE, 0.35)

## Mostra a tecla do teclado ou o ícone do botão do controle, conforme o
## dispositivo em uso.
func _refresh_key() -> void:
	var glyph: Texture2D = null
	if InputDeviceManager.using_gamepad:
		glyph = InputDeviceManager.glyph_for_action(input_action)

	key_icon.texture = glyph
	key_icon.visible = glyph != null
	key_label.visible = glyph == null
	key_label.text = _key_text()
	# O ícone do controle já é um botão redondo: esconde o fundo branco do selo.
	key_badge.self_modulate.a = 0.0 if glyph else 1.0

func _key_text() -> String:
	for event in InputMap.action_get_events(input_action):
		if event is InputEventKey:
			return (event as InputEventKey).as_text_physical_keycode()
	return "?"
