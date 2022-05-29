extends "res://Scripts/WireRamp.gd"


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func on_GameState_changed(new_stage, is_debug_skip):
	if new_stage <= GameState.PREGAME_STATE:
		reset(true)
	elif new_stage == GameState.BOSS_APPEARS_STATE:
		reset(false)
	elif is_debug_skip:
		if new_stage <= GameState.ENEMY_FLEET_STATE:
			reset(true)
		else:
			reset(false)
