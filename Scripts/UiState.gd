class_name UiState
extends "res://Scripts/State.gd"

onready var ui_nodes := get_node("UiNodes") as Control

func _on_enter(params := {}):
	ui_nodes.visible = true
	var sub_states_parent = _find_sub_states_parent() as Control
	if sub_states_parent:
		sub_states_parent.visible = true
	var components_parent = _find_components_parent() as Control
	if components_parent:
		components_parent.visible = true
	._on_enter(params)

func _on_exit(passthrough_params := {}) -> Dictionary:
	ui_nodes.visible = false
	var sub_states_parent = _find_sub_states_parent() as Control
	if sub_states_parent:
		sub_states_parent.visible = false
	var components_parent = _find_components_parent() as Control
	if components_parent:
		components_parent.visible = false
	return ._on_exit(passthrough_params)
