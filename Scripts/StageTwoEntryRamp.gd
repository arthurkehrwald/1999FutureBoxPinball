extends "res://Scripts/PseudoPhysicsPathFollow.gd"

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage is GameState.stage.PREGAME:
		reset(true)
