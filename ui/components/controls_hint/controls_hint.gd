extends Panel

@export var tempo_exibicao: float = 4.0
@export var duracao_fade: float = 1.5

@onready var keyboard_row: Control = $Content/KeyboardRow
@onready var gamepad_row: Control = $Content/GamepadRow
@onready var gamepad_shoot_icon: TextureRect = $Content/GamepadRow/ShootGlyph

func _ready() -> void:
	modulate.a = 1.0
	gamepad_shoot_icon.texture = InputDeviceManager.glyph_for_action(&"shoot")
	_atualizar_dispositivo(InputDeviceManager.using_gamepad)
	InputDeviceManager.device_changed.connect(_atualizar_dispositivo)

	var tween = create_tween()
	tween.tween_interval(tempo_exibicao)
	tween.tween_property(self, "modulate:a", 0.0, duracao_fade)
	tween.tween_callback(queue_free)

func _atualizar_dispositivo(using_gamepad: bool) -> void:
	keyboard_row.visible = not using_gamepad
	gamepad_row.visible = using_gamepad
