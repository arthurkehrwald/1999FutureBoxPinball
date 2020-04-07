extends "res://Scripts/PseudoPhysicsPathFollow.gd"

func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")
	
func _on_GameState_changed(new_stage, is_debug_skip):
	if new_stage == GameState.PREGAME:
		reset(true)
	elif new_stage == GameState.BOSS_BEGIN:
		reset(false)
	elif is_debug_skip:
		if new_stage == GameState.EXPOSITION or new_stage == GameState.ENEMY_FLEET:
			reset(true)
		else:
			reset(false)
