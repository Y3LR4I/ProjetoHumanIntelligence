extends Control

@onready var glitch_overlay = $GlitchOverlay
@onready var credits_content = $CreditsContent
@onready var title = $CreditsContent/Title
@onready var terminal_text = $CreditsContent/TerminalText
@onready var members = $CreditsContent/Members
@onready var footer = $CreditsContent/Footer
@onready var back_button = $BackButton
@onready var game_title = $CreditsContent/GameTitle

var glitch_tween: Tween


const TERMINAL_LINES = [
	"> ACCESSING PERSONNEL DATABASE...",
	"> VERIFYING IDENTITIES...",
	"> ACCESS GRANTED.",
	"> LOADING CREDITS..."
]

func _ready() -> void:
	glitch_overlay.visible = false

	# Visíveis desde o início
	title.modulate.a = 1.0
	back_button.modulate.a = 1.0

	# Elementos que aparecem depois
	terminal_text.modulate.a = 1.0
	game_title.modulate.a = 0.0
	members.modulate.a = 1.0
	footer.modulate.a = 0.0

	for membro in members.get_children():
		membro.modulate.a = 0.0

	InputDeviceManager.focus_when_gamepad(back_button)

	await get_tree().create_timer(0.5).timeout

	# 1. Digitação das mensagens
	await digitar_terminal()

	# 2. Aparece o nome do jogo
	await aparecer_elemento(game_title)

	# 3. Aparecem os integrantes
	for membro in members.get_children():
		await aparecer_elemento(membro)

	# 4. Aparece o rodapé
	await aparecer_elemento(footer)
	
func aparecer_elemento(elemento: CanvasItem) -> void:
	var tween = create_tween()
	tween.tween_property(elemento, "modulate:a", 1.0, 0.6)
	await tween.finished

	await get_tree().create_timer(0.3).timeout

func iniciar_glitch() -> void:
	glitch_overlay.visible = true
	glitch_overlay.modulate.a = 0.0

	glitch_tween = create_tween()

	# Primeiro flash
	glitch_tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.05)
	glitch_tween.tween_interval(0.04)

	# Apaga rapidamente
	glitch_tween.tween_property(glitch_overlay, "modulate:a", 0.0, 0.04)
	glitch_tween.tween_interval(0.06)

	# Segundo flash
	glitch_tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.03)
	glitch_tween.tween_interval(0.08)

	# Tela preta
	glitch_tween.tween_property(glitch_overlay, "modulate:a", 1.0, 0.1)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://features/menu/menu.tscn")
	

func digitar_terminal():
	terminal_text.text = ""

	for linha in TERMINAL_LINES:
		for caractere in linha:
			terminal_text.text += caractere
			await get_tree().create_timer(0.035).timeout

		terminal_text.text += "\n"
		await get_tree().create_timer(0.5).timeout

func animar_entrada():
	var elementos = [
		title,
		terminal_text,
		members.get_node("Member1"),
		members.get_node("Member2"),
		members.get_node("Member3"),
		footer
	]

	for elemento in elementos:
		elemento.modulate.a = 0.0

	await get_tree().create_timer(0.3).timeout

	for elemento in elementos:
		var tween = create_tween()
		tween.tween_property(elemento, "modulate:a", 1.0, 0.5)
		await tween.finished
		await get_tree().create_timer(0.25).timeout
