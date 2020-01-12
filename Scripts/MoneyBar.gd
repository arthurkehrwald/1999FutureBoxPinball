extends "res://Scripts/Bar.gd"

func _enter_tree():
	GameState.connect("player_money_changed", self, "_on_value_changed")

func _ready():
	value = GameState.player_money
	max_value = GameState.MAX_PLAYER_MONEY
