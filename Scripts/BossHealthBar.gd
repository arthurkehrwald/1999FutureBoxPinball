extends "res://Scripts/Bar.gd"

func _enter_tree():
	GameState.connect("boss_health_changed", self, "_on_value_changed")

func _ready():
	value = GameState.boss_health
	max_value = GameState.max_boss_health
