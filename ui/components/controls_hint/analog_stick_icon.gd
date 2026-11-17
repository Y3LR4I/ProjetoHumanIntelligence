extends Control

func _draw() -> void:
	var center := size / 2.0
	var outer_radius: float = size.x / 2.0 - 2.0
	draw_circle(center, outer_radius, Color(1, 1, 1, 0.12))
	draw_arc(center, outer_radius, 0, TAU, 32, Color(1, 1, 1, 0.35), 1.5, true)
	draw_circle(center, outer_radius * 0.45, Color(1, 1, 1, 0.8))
