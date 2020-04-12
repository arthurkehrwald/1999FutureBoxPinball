extends "res://Scripts/WireRamp.gd"


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func on_GameState_changed(new_stage, is_debug_skip):
	if new_stage <= GameState.PREGAME:
		reset(true)
	elif new_stage == GameState.BOSS_APPEARS:
		reset(false)
	elif is_debug_skip:
		if new_stage <= GameState.ENEMY_FLEET:
			reset(true)
		else:
			reset(false)
