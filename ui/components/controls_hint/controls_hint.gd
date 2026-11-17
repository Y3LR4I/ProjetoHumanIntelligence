extends Panel

@export var tempo_exibicao: float = 4.0
@export var duracao_fade: float = 1.5

func _ready() -> void:
	modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(tempo_exibicao)
	tween.tween_property(self, "modulate:a", 0.0, duracao_fade)
	tween.tween_callback(queue_free)
