extends "res://Scripts/WireRamp.gd"

export var TRIGGER_PROGRESS = .5

onready var looping_louie = get_node("LoopingLouie")


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
