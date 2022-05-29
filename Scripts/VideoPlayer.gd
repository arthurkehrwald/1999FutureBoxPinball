extends VideoPlayer


onready var video = {
	GameState.TESTING_STATE: null,
	GameState.PREGAME_STATE: preload("res://HUD/Videos/pregame_overlay.ogv"),
	GameState.EXPOSITION_STATE: null,
	GameState.ENEMY_FLEET_STATE: preload("res://HUD/Videos/stage_one_overlay.ogv"),
	GameState.BOSS_APPEARS_STATE: preload("res://HUD/Videos/stage_two_overlay.ogv"),
	GameState.MISSILES_STATE: null,
	GameState.TREX_STATE: null,
	GameState.BLACK_HOLE_STATE: null,
	GameState.ECLIPSE_STATE: null,
	GameState.VICTORY_STATE: null,
	GameState.DEFEAT_STATE: preload("res://HUD/Videos/game_over_overlay.ogv")
}


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	connect("finished", self, "on_finished")


func on_GameState_changed(new_state, is_debug_skip):
	if not is_debug_skip and video[new_state] != null:
		stream = video[new_state]
		visible = true
		get_tree().paused = true
		play()
	else:
		visible = false
		get_tree().paused = false
		stop()


func on_finished():
	visible = false
	get_tree().paused = false
	GameState.handle_event(GameState.Event.POSTGAME_FINISHED)
