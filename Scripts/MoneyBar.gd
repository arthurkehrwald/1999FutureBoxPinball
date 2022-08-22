extends "res://Scripts/Bar.gd"

func _enter_tree():
	# TODO GameState.connect("player_money_changed", self, "update_value")

func _ready():
	value = GameState.player_money
	max_value = GameState.MAX_PLAYER_MONEY
