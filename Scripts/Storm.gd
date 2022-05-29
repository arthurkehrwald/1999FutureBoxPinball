extends Area


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func on_GameState_changed(new_stage, _is_debug_skip):
	set_is_active(new_stage < GameState.BOSS_APPEARS_STATE)


func set_is_active(is_active):
	set_visible(is_active)
	set_deferred("monitoring", is_active)
	set_deferred("monitorable", is_active)
