extends Node2D

const HEALTH_BAR_WIDTH = 300.0
const CRITICAL_RATIO = 0.25

@onready var player = $player
@onready var pause_menu = $UILayer/PauseMenu
@onready var name_entry = $UILayer/NameEntry
@onready var score_label = $UILayer/ScoreLabel
@onready var health_value_label = $UILayer/HealthBar/HealthValueLabel
@onready var health_bar_fill = $UILayer/HealthBar/HealthBarFill
@onready var health_bar_glow = $UILayer/HealthBar/HealthBarGlow
@onready var health_bar_ticks = $UILayer/HealthBar/HealthBarTicks
@onready var enemy_spawner = $EnemySpawner

var _critical_tween: Tween

func _ready() -> void:
	pause_menu.restart_requested.connect(_on_restart_requested)
	pause_menu.exit_requested.connect(_on_exit_requested)
	name_entry.name_submitted.connect(_on_name_submitted)

	player.health_component.died.connect(_on_player_died)
	player.health_component.health_changed.connect(_on_health_changed)
	_criar_marcas_da_barra(player.health_component.max_health)
	_atualizar_barra_de_vida(player.health_component.health, false)

	ScoreManager.resetar_score()
	ScoreManager.score_changed.connect(_on_score_changed)
	_on_score_changed(ScoreManager.score)

	enemy_spawner.start()

func _on_score_changed(score: int) -> void:
	score_label.text = "PONTOS: %d" % score

func _on_health_changed(health: float) -> void:
	_atualizar_barra_de_vida(health, true)

func _criar_marcas_da_barra(max_health: float) -> void:
	for filho in health_bar_ticks.get_children():
		filho.queue_free()

	var pontos = int(ceil(max_health))
	for i in range(1, pontos):
		var tick = ColorRect.new()
		tick.color = Color(0, 0, 0, 0.35)
		tick.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tick.position = Vector2(HEALTH_BAR_WIDTH * (float(i) / float(pontos)) - 1.0, 0.0)
		tick.size = Vector2(2.0, 22.0)
		health_bar_ticks.add_child(tick)

func _atualizar_barra_de_vida(health: float, animar: bool) -> void:
	var max_health = player.health_component.max_health
	var ratio = clamp(health / max_health, 0.0, 1.0)
	var largura_alvo = HEALTH_BAR_WIDTH * ratio
	var cor_alvo = _cor_da_vida(ratio)

	health_value_label.text = "%d/%d" % [int(ceil(max(health, 0.0))), int(ceil(max_health))]

	if animar:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(health_bar_fill, "size:x", largura_alvo, 0.25)
		tween.tween_property(health_bar_fill, "color", cor_alvo, 0.25)
	else:
		health_bar_fill.size.x = largura_alvo
		health_bar_fill.color = cor_alvo

	_atualizar_pulso_critico(ratio)

func _cor_da_vida(ratio: float) -> Color:
	if ratio > 0.5:
		return Color(0.85, 0.75, 0.2).lerp(Color(0.3, 0.85, 0.45), (ratio - 0.5) * 2.0)
	return Color(0.9, 0.25, 0.25).lerp(Color(0.85, 0.75, 0.2), ratio * 2.0)

func _atualizar_pulso_critico(ratio: float) -> void:
	var critico = ratio > 0.0 and ratio <= CRITICAL_RATIO

	if critico and _critical_tween == null:
		_critical_tween = create_tween()
		_critical_tween.set_loops()
		_critical_tween.tween_property(health_bar_glow, "color:a", 0.35, 0.4)
		_critical_tween.tween_property(health_bar_glow, "color:a", 0.0, 0.4)
	elif not critico and _critical_tween != null:
		_critical_tween.kill()
		_critical_tween = null
		health_bar_glow.color.a = 0.0

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
