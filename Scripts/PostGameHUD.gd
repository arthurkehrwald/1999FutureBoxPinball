extends Control

export var RESTART_DELAY = 10.0

onready var restart_timer = get_node("RestartTimer")
onready var time_remaining_bar= get_node("TimeRemainingBar")
onready var time_remaining_label = get_node("TimeRemainingLabel")
onready var result_label = get_node("ResultLabel")

var is_active = false

func _ready():
	restart_timer.connect("timeout", self, "on_RestartTimer_timeout")
	time_remaining_bar.max_value = RESTART_DELAY * 100
	set_process(false)
	set_is_active(false)


func _process(_delta):
	time_remaining_label.text = str(round(restart_timer.time_left))
	time_remaining_bar.value = restart_timer.time_left * 100


func set_is_active(value):
	is_active = value
	set_visible(value)
	set_process(value)
	if value:
		restart_timer.start(RESTART_DELAY)


func on_RestartTimer_timeout():
	set_is_active(false)
