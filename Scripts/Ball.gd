extends "res://Scripts/BallBombCommon.gd"
	
func _ready():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func back_to_spawn():
	set_locked(false)
	set_visible(true)
	teleport(start_pos, false, Vector3(.0,.0,.0))

func delete():
	GameState.balls_on_field -= 1
	owner.queue_free()

func _on_GameState_global_reset():
	delete()
