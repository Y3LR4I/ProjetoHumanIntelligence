
extends Control

@export var bar_texture: Texture2D

@onready var bars = $Bars

const MAX_BARS = 7
var current_bars = MAX_BARS
var bar_nodes = []

func _ready():
	for i in range(MAX_BARS):
		var bar = TextureRect.new()
		bar.texture = bar_texture
		bar.custom_minimum_size = Vector2(18, 70)
		bar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

		bars.add_child(bar)
		bar_nodes.append(bar)

func update_health(health: float):
	current_bars = clampi(int(health), 0, MAX_BARS)

	for i in range(MAX_BARS):
		bar_nodes[i].visible = i < current_bars
