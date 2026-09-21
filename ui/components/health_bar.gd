class_name HealthBar
extends HBoxContainer

const TAMANHO_CORACAO: float = 32.0

var _coracoes: Array[ColorRect] = []


func atualizar(atual: float, maxima: float) -> void:
	var total := int(ceil(maxima))
	_garantir_quantidade(total)
	for i in total:
		var vida_do_coracao := clampf(atual - float(i), 0.0, 1.0)
		var coracao := _coracoes[i]
		if vida_do_coracao > 0.0:
			coracao.color = Color(0.9, 0.25, 0.3)
			coracao.modulate.a = 0.35 + 0.65 * vida_do_coracao
		else:
			coracao.color = Color(0.3, 0.3, 0.32)
			coracao.modulate.a = 1.0


func _garantir_quantidade(total: int) -> void:
	while _coracoes.size() < total:
		var coracao := ColorRect.new()
		coracao.custom_minimum_size = Vector2(TAMANHO_CORACAO, TAMANHO_CORACAO)
		coracao.color = Color(0.9, 0.25, 0.3)
		add_child(coracao)
		_coracoes.append(coracao)
