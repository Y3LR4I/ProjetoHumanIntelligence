extends Node

signal health_changed(health)
signal died
## Emitido quando um dano é ignorado por invulnerabilidade (ex: escudo).
signal damage_blocked

@export var max_health: float = 4.0
@export var laser_damage: float = 0.5

var health: float
var invulnerable: bool = false

func _ready():
	health = max_health

func take_damage(amount: float):
	# Já morto (dois acertos no mesmo frame): evita somar pontos duas vezes.
	if health <= 0:
		return
	if invulnerable:
		damage_blocked.emit()
		return

	health -= amount

	if get_parent().name == "player":
		print("Dano recebido: ", amount)
		print("Vida do Player: ", health, "/", max_health)

	health_changed.emit(health)

	if health <= 0:
		died.emit()

		var parent = get_parent()
		if parent.has_node("ScoreComponent"):
			ScoreManager.adicionar_pontos(parent.get_node("ScoreComponent").score)

		parent.queue_free()

func take_laser_hit() -> void:
	take_damage(laser_damage)
