class_name Mission
extends "res://Scripts/State.gd"

export var objective: String = "Objective"

var is_complete = false

func _on_enter(params := {}):
	is_complete = false
	._on_enter(params)

func _on_exit(passthrough_params := {}) -> Dictionary:
	var params := {"is_complete": is_complete}
	params = Utils.merge_dict(params, passthrough_params)
	return ._on_exit(params)

func _on_mission_completed():
	is_complete = true
	exit()

func _on_mission_failed():
	is_complete = false
	exit()

func _enter_tree():
	add_to_group("missions")
