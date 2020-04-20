extends VideoPlayer

func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	connect("finished", self, "on_finished")


func on_GameState_changed(new_state, _is_debug_skip):
	if new_state == GameState.DEFEAT:
		set_visible(true)
		play()
	else:
		set_visible(false)
		stop()


func on_finished():
	set_visible(false)
	GameState.handle_event(GameState.Event.POSTGAME_FINISHED)
