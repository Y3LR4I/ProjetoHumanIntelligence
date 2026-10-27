extends Control

signal restart_requested
signal exit_requested

const FONT_SIZE_NORMAL = 40
const FONT_SIZE_HOVER = 45

@onready var resume_button = $ResumeButton
@onready var restart_button = $RestartButton
@onready var exit_button = $ExitButton

var _can_pause: bool = true


func _ready():
	configurar_botao(resume_button, "CONTINUAR", "CONTINUAR")
	configurar_botao(restart_button, "REINICIAR", "REINICIAR")
	configurar_botao(exit_button, "SAIR", "SAIR")

	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(func(): restart_requested.emit())
	exit_button.pressed.connect(func(): exit_requested.emit())


func _unhandled_input(event: InputEvent) -> void:
	if _can_pause and event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	visible = get_tree().paused


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func disable() -> void:
	_can_pause = false
	get_tree().paused = false
	visible = false


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
