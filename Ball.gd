extends "res://Scripts/BallBombCommon.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_reset_ball")
	GameState.connect("reset_ball", self,"_on_GameState_reset_ball")
	
func _on_GameState_reset_ball():
	set_locked(false)
	teleport(start_pos, false, Vector3(.0,.0,.0))
