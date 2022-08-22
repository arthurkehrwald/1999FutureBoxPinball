extends "res://Scripts/WireRamp.gd"

export var TRIGGER_PROGRESS = .5

onready var looping_louie = get_node("LoopingLouie")


func _ready():
	# TODO GameState.connect("state_changed", self, "on_GameState_changed")


func _physics_process(_delta):
	if looping_louie.is_flying:
		return
	var was_triggered = false
	if looping_body_entered_status == states.AT_ENTRANCE:
		was_triggered = path_follow.get_unit_offset() > TRIGGER_PROGRESS
	elif looping_body_entered_status == states.AT_EXIT:
		was_triggered = path_follow.get_unit_offset() < TRIGGER_PROGRESS
	if was_triggered: 
		looping_louie.start_flying()


func on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME_STATE:
		reset(true)
