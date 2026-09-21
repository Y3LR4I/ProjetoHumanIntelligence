class_name Projectile
extends Area2D

@export var speed: float = 500.0

var _direcao: Vector2 = Vector2.UP
var _dano: float = 1.0
var _grupo_alvo: String = ""
var _alcance_maximo: float = 0.0
var _distancia_percorrida: float = 0.0


func configurar(direcao: Vector2, dano: float, grupo_alvo: String, alcance_maximo: float = 0.0) -> void:
	_direcao = direcao.normalized()
	_dano = dano
	_grupo_alvo = grupo_alvo
	_alcance_maximo = alcance_maximo
	rotation = _direcao.angle() + PI / 2.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float) -> void:
	var deslocamento := _direcao * speed * delta
	position += deslocamento

	if _alcance_maximo <= 0.0:
		return
	_distancia_percorrida += deslocamento.length()
	if _distancia_percorrida >= _alcance_maximo:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group(_grupo_alvo):
		return
	if area.has_method("sofrer_dano"):
		area.sofrer_dano(_dano)
	queue_free()


func _on_screen_exited() -> void:
	queue_free()
