extends Node

## Sorteia um drop quando um inimigo é destruído por dano (inimigo que passa
## da borda inferior não dropa). Regras:
## - só um upgrade na tela por vez, e só se algum tipo cadastrado puder cair
##   (`add_drop_option`, ex: o player ainda tem espaço pra mais uma carga do
##   escudo, ou ainda não está com a vida cheia);
## - depois de um drop, espera `min_time_between_drops` pra poder cair outro;
## - a partir daí cada inimigo destruído tem `drop_chance` de dropar;
## - passado `guaranteed_after` sem drop, o próximo inimigo destruído dropa
##   com certeza (dá constância, sem depender só da sorte);
## - na hora de dropar, sorteia com igual chance entre os tipos elegíveis.
## O relógio só corre enquanto um drop é possível. Os valores vêm do nível de
## dificuldade atual.

@export_range(0.0, 1.0) var drop_chance: float = 0.08
@export var min_time_between_drops: float = 40.0
@export var guaranteed_after: float = 75.0

var _drop_options: Array[Dictionary] = []
var _time_since_last_drop: float = 0.0

## Cadastra um tipo de upgrade que pode cair. `can_drop` diz se esse tipo
## faz sentido dropar agora (ex: o player ainda tem espaço pra ele).
func add_drop_option(scene: PackedScene, can_drop: Callable) -> void:
	_drop_options.append({"scene": scene, "can_drop": can_drop})

## Chamado quando o nível de dificuldade muda (config do DifficultyManager).
func configurar_dificuldade(config: Dictionary) -> void:
	drop_chance = config.get("chance_escudo", drop_chance)
	min_time_between_drops = config.get("intervalo_escudo", min_time_between_drops)
	guaranteed_after = config.get("garantia_escudo", guaranteed_after)

func _process(delta: float) -> void:
	if _drop_possible():
		_time_since_last_drop += delta

func track(enemy: Node) -> void:
	var health_component = enemy.get_node_or_null("HealthComponent")
	if health_component:
		health_component.died.connect(_on_enemy_died.bind(enemy), CONNECT_ONE_SHOT)

func _drop_possible() -> bool:
	return get_tree().get_nodes_in_group("pickups").is_empty() and not _eligible_scenes().is_empty()

func _eligible_scenes() -> Array[PackedScene]:
	var eligible: Array[PackedScene] = []
	for option in _drop_options:
		if option["can_drop"].call():
			eligible.append(option["scene"])
	return eligible

func _on_enemy_died(enemy: Node2D) -> void:
	if not _drop_possible():
		return
	if _time_since_last_drop < min_time_between_drops:
		return
	var guaranteed: bool = _time_since_last_drop >= guaranteed_after
	if not guaranteed and randf() > drop_chance:
		return

	_time_since_last_drop = 0.0

	var eligible := _eligible_scenes()
	var scene: PackedScene = eligible[randi() % eligible.size()]
	var pickup = scene.instantiate()
	pickup.position = enemy.global_position
	# Deferred: a morte pode acontecer no meio de um callback de física.
	get_tree().current_scene.add_child.call_deferred(pickup)
