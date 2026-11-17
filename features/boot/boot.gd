extends Control

@onready var title = $Title
@onready var cursor = $Cursor
@onready var typing_sound = get_node_or_null("TypingSound")

var texto = "Human Intelligence"
var indice = 0

func _ready():
	print("Cena atual: ", get_tree().current_scene.scene_file_path)
	print("Filhos do Opening: ", get_children())

	title.text = ""
	cursor.visible = false
	typing_sound.play()
	$TypeTimer.start()

func _on_type_timer_timeout() -> void:
	if indice < texto.length():
		indice += 1
		title.text = texto.substr(0, indice)
	else:
		$TypeTimer.stop()
		typing_sound.stop()
		$CursorTimer.start()
		cursor.visible = true
		$TransitionTimer.start()

func _on_cursor_timer_timeout() -> void:
	cursor.visible = !cursor.visible

func _on_transition_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://features/menu/menu.tscn")
