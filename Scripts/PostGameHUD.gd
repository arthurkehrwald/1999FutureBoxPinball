extends Control

enum Result {VICTORY, DEFEAT}

export var RESTART_DELAY = 10.0

onready var _restart_timer = get_node("RestartTimer")
onready var _time_remaining_bar = get_node("TimeRemainingBar")
onready var _time_remaining_label = get_node("TimeRemainingLabel")
onready var _result_label = get_node("ResultLabel")

var is_active = false

func _ready():
	GameState.connect("state_changed", self, "_on_GameState_changed")
	_time_remaining_bar.max_value = RESTART_DELAY * 100
	set_process(false)


func _set_is_active(value):
	is_active = value
	get_tree().paused = value
	set_visible(value)
	set_process(value)
	_restart_timer.start(RESTART_DELAY)


func _display_result(has_player_won):
	if has_player_won:
		Announcer.say("victory")
		_result_label.text = "Victory!"
	else:
		Announcer.say("sux")
		_result_label.text = "You Lose!"
	_restart_timer.start()


func _process(_delta):
	_time_remaining_label.text = str(round(_restart_timer.time_left))
	_time_remaining_bar.value = _restart_timer.time_left * 100


func _on_RestartTimer_timeout():
	_set_is_active(false)
	GameState.handle_event(GameState.Event.POSTGAME_FINISHED)


func _on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.VICTORY:
		_display_result(Result.VICTORY)
		_set_is_active(true)
	elif new_state == GameState.DEFEAT:
		_display_result(Result.DEFEAT)
		_set_is_active(true)
	elif new_state == GameState.PREGAME or is_debug_skip:
		_set_is_active(false)
