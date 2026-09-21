extends Node

const CENA_BOOT := "res://features/boot/boot.tscn"
const CENA_MENU := "res://features/menu/menu.tscn"
const CENA_JOGO := "res://features/game/game.tscn"


func ir_para_boot() -> void:
	get_tree().change_scene_to_file(CENA_BOOT)


func ir_para_menu() -> void:
	get_tree().change_scene_to_file(CENA_MENU)


func ir_para_jogo() -> void:
	get_tree().change_scene_to_file(CENA_JOGO)
