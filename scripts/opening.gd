extends Control

@onready var title = $Title
@onready var cursor = $Cursor

var texto = "Human Intelligence"
var indice = 0

func _ready():
	title.text = ""
	cursor.visible = false
	$TypeTimer.start()

func _on_type_timer_timeout() -> void:
	if indice < texto.length():
		indice += 1
		title.text = texto.substr(0, indice)
	else:
		$TypeTimer.stop()
		$CursorTimer.start()
		cursor.visible = true
		$TransitionTimer.start()

func _on_cursor_timer_timeout() -> void:
	cursor.visible = !cursor.visible

func _on_transition_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
