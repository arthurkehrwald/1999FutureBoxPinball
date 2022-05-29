extends Control

export var RESTART_DELAY = 10.0

onready var restart_timer = get_node("RestartTimer")
onready var time_remaining_bar= get_node("TimeRemainingBar")
onready var time_remaining_label = get_node("TimeRemainingLabel")
onready var result_label = get_node("ResultLabel")

var is_active = false

func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	restart_timer.connect("timeout", self, "on_RestartTimer_timeout")
	time_remaining_bar.max_value = RESTART_DELAY * 100
	set_process(false)


func _process(_delta):
	time_remaining_label.text = str(round(restart_timer.time_left))
	time_remaining_bar.value = restart_timer.time_left * 100


func set_is_active(value):
	is_active = value
	#get_tree().paused = value
	set_visible(value)
	set_process(value)
	if value:
		restart_timer.start(RESTART_DELAY)


func on_RestartTimer_timeout():
	set_is_active(false)
	GameState.handle_event(GameState.Event.POSTGAME_FINISHED)


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.VICTORY_STATE:
		result_label.text = "Victory!"
		set_is_active(true)
#	elif new_state == GameState.DEFEAT_STATE:
#		result_label.text = "You Lose!"
#		set_is_active(true)
	elif new_state == GameState.PREGAME_STATE or is_debug_skip:
		set_is_active(false)
