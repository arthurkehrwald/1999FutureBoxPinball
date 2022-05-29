extends "res://Scripts/WireRamp.gd"


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME_STATE:
		reset(true)
