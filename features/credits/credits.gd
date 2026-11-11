extends Control

const FONT_SIZE_NORMAL = 50
const FONT_SIZE_HOVER = 55
const FADE_IN_DURATION = 1.5

const CREDITS_DATA: Array[Dictionary] = [
	{"name": "Dhenzel Lima", "role": "Desenvolvedor, Infraestrutura"},
	{"name": "Iarley Alves", "role": "Desenvolvedor, Designer UI/UX"},
	{"name": "João Victor", "role": "Desenvolvedor, Infraestrutura"},
]

@onready var credits_container = $CreditsScroll/CreditsContainer
@onready var credits_scroll = $CreditsScroll
@onready var back_button = $BackButton
@onready var title = $Title
@onready var subtitle = $Subtitle
@onready var background = $Background
@onready var fade_overlay = $FadeOverlay
@onready var empty_label = $EmptyLabel


func _ready():
	_popular_creditos(CREDITS_DATA)
	_animar_entrada()
	configurar_botao(back_button, "VOLTAR", "VOLTAR")
	back_button.pressed.connect(_on_back_pressed)


func _popular_creditos(entries: Array):
	for i in range(credits_container.get_child_count()):
		credits_container.get_child(i).queue_free()

	if entries.is_empty():
		empty_label.visible = true
		credits_scroll.visible = false
		return

	empty_label.visible = false
	credits_scroll.visible = true

	for entry in entries:
		var role: String = entry.get("role", "")
		var name: String = entry.get("name", "")
		credits_container.add_child(_criar_entrada_credito(name, role))


func _criar_entrada_credito(name: String, role: String) -> VBoxContainer:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)
	container.custom_minimum_size = Vector2(0, 70)

	var name_label = Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 40)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_color_override("font_color", Color.WHITE)
	container.add_child(name_label)

	var role_label = Label.new()
	role_label.text = role
	role_label.add_theme_font_size_override("font_size", 22)
	role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	container.add_child(role_label)

	return container


func _animar_entrada():
	var elementos = [background, fade_overlay, title, subtitle, credits_scroll, back_button, empty_label]

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


func _on_back_pressed():
	get_tree().change_scene_to_file("res://features/menu/menu.tscn")
