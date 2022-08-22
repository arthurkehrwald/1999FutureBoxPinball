class_name Mission
extends "res://Scripts/State.gd"

export var objective: String = "Objective"

var is_complete = false

func _on_enter():
	is_complete = false
	._on_enter()

func _on_exit():
	if not is_complete:
		_on_mission_failed()
	._on_exit()

func _on_mission_completed():
	is_complete = true
	exit()

func _on_mission_failed():
	is_complete = false
	exit()

func _enter_tree():
	add_to_group("missions")
