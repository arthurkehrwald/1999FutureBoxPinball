class_name Mission
extends "res://Scripts/State.gd"

signal completed
signal failed

export var objective: String = "Objective"

var is_complete = false

func enter():
	.enter()
	is_complete = false

func exit():
	.exit()
	if not is_complete:
		_on_mission_failed()

func _on_mission_completed():
	is_complete = true
	emit_signal("completed")

func _on_mission_failed():
	is_complete = false
	emit_signal("failed")

func _enter_tree():
	add_to_group("missions")
