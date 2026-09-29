extends Node2D

@onready var player = $player

func _on_boundary_damage_area_body_entered(body: Node2D) -> void:
	if body.has_node("BoundaryDamage"):
		var boundary_damage = body.get_node("BoundaryDamage")
		
		boundary_damage.causar_dano(player)
		body.destruir_na_borda()
