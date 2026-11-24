extends Node2D

const SHIELD_PICKUP_SCENE = preload("res://features/game/entities/pickups/shield_pickup/shield_pickup.tscn")
const BATTERY_PICKUP_SCENE = preload("res://features/game/entities/pickups/battery_pickup/battery_pickup.tscn")

@onready var player = $player
@onready var pause_menu = $UILayer/PauseMenu
@onready var name_entry = $UILayer/NameEntry
@onready var score_label = $UILayer/ScoreLabel
@onready var enemy_spawner = $EnemySpawner
@onready var difficulty_manager = $DifficultyManager
@onready var shoot_slot = $HUD/PowerBar/ShootSlot
@onready var laser_cannon_slot = $HUD/PowerBar/LaserCannonSlot
@onready var shield_slot = $HUD/PowerBar/ShieldSlot
@onready var loot_dropper = $LootDropper
@onready var game_music = $GameMusic

func _ready() -> void:
	pause_menu.restart_requested.connect(_on_restart_requested)
	pause_menu.exit_requested.connect(_on_exit_requested)
	name_entry.name_submitted.connect(_on_name_submitted)

	player.health_component.died.connect(_on_player_died)
	player.laser_cannon.status_changed.connect(laser_cannon_slot.update_status)
	player.laser_cannon.status_changed.connect(_on_laser_cannon_status_changed)
	player.shot_fired.connect(shoot_slot.pulse)
	player.shield.status_changed.connect(shield_slot.update_status)

	# Carga de escudo só cai se o player ainda puder guardar mais uma, e a
	# bateria só cai se ele não estiver com a vida cheia.
	loot_dropper.add_drop_option(SHIELD_PICKUP_SCENE, player.shield.can_receive_charge)
	loot_dropper.add_drop_option(BATTERY_PICKUP_SCENE, player.health_component.can_receive_heal)
	enemy_spawner.enemy_spawned.connect(loot_dropper.track)

	ScoreManager.resetar_score()
	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)
	
	game_music.stream.loop = true
	game_music.play()

	difficulty_manager.dificuldade_alterada.connect(_on_dificuldade_alterada)
	enemy_spawner.configurar_dificuldade(difficulty_manager.get_config())
	loot_dropper.configurar_dificuldade(difficulty_manager.get_config())
	enemy_spawner.start()

func _on_score_changed(score: int) -> void:
	score_label.text = "%d" % score

func _on_dificuldade_alterada(_nivel: int, config: Dictionary) -> void:
	enemy_spawner.configurar_dificuldade(config)
	loot_dropper.configurar_dificuldade(config)

# O tiro normal fica bloqueado enquanto o canhão laser está ativo.
func _on_laser_cannon_status_changed(state: StringName, _remaining: float, _total: float) -> void:
	shoot_slot.update_status(&"blocked" if state == &"active" else &"ready", 0.0, 1.0)

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
