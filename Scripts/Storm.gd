extends Area

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _on_GameState_stage_changed(new_stage, is_debug_skip):
	match new_stage:
		GameState.PREGAME:
			set_is_active(true)
		GameState.BOSS_BEGIN:
			set_is_active(false)
	if is_debug_skip:
		if new_stage == GameState.EXPOSITION or new_stage == GameState.ENEMY_FLEET:
			set_is_active(true)
		else:
			set_is_active(false)
	
func set_is_active(is_active):
	set_visible(is_active)
	set_deferred("monitoring", is_active)
	set_deferred("monitorable", is_active)
