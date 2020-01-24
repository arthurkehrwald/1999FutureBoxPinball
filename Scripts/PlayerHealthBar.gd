extends "res://Scripts/Bar.gd"

func _enter_tree():
	GameState.connect("player_health_changed", self, "_on_value_changed")

func _ready():
	value = GameState.player_health
	max_value = GameState.max_player_health
	print("PlayerHealthBar: max_value - ", max_value)
