extends "res://Scripts/PseudoPhysicsPathFollow.gd"

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if new_stage == GameState.stage.PREGAME:
		reset(true)
	elif new_stage == GameState.stage.BOSS_BEGIN:
		reset(false)
	elif is_debug_skip:
		if new_stage == GameState.stage.EXPOSITION or new_stage == GameState.stage.ENEMY_FLEET:
			reset(true)
		else:
			reset(false)
