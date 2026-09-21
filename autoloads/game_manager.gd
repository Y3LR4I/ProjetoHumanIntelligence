extends Node

signal pontuacao_alterada(nova_pontuacao: int)

var pontuacao: int = 0
var vida_restante_ao_final: float = 0.0


func adicionar_pontuacao(pontos: int) -> void:
	pontuacao += pontos
	pontuacao_alterada.emit(pontuacao)


func registrar_fim_de_partida(vida_final: float) -> void:
	vida_restante_ao_final = vida_final


func reiniciar_estado() -> void:
	pontuacao = 0
	vida_restante_ao_final = 0.0
	pontuacao_alterada.emit(pontuacao)
