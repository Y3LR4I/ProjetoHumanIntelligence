extends Node2D

@onready var player = $player
@onready var pause_menu = $UILayer/PauseMenu
@onready var name_entry = $UILayer/NameEntry
@onready var score_label = $UILayer/ScoreLabel
@onready var enemy_spawner = $EnemySpawner

func _ready() -> void:
	pause_menu.restart_requested.connect(_on_restart_requested)
	pause_menu.exit_requested.connect(_on_exit_requested)
	name_entry.name_submitted.connect(_on_name_submitted)

	player.health_component.died.connect(_on_player_died)

	ScoreManager.resetar_score()
	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)

	enemy_spawner.start()

func _on_score_changed(score: int) -> void:
	score_label.text = "PONTOS: %d" % score

func _on_player_died() -> void:
	enemy_spawner.stop()
	pause_menu.disable()
	get_tree().paused = true
	name_entry.open(ScoreManager.score)

func _on_name_submitted(player_name: String) -> void:
	ScoreboardManager.score_submitted.connect(_on_score_submitted, CONNECT_ONE_SHOT)
	ScoreboardManager.submit_score(player_name, ScoreManager.score)

func _on_score_submitted(success: bool) -> void:
	if success:
		get_tree().paused = false
		get_tree().change_scene_to_file("res://features/scoreboard/scoreboard.tscn")
	else:
		name_entry.set_status("Falha ao salvar. Tente novamente.")

func _on_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://features/menu/menu.tscn")

func _on_boundary_damage_area_body_entered(body: Node2D) -> void:
	if body.has_node("BoundaryDamage"):
		var boundary_damage = body.get_node("BoundaryDamage")

		boundary_damage.causar_dano(player)
		body.destruir_na_borda()
