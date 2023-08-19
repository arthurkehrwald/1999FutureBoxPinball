class_name UiState
extends "res://Scripts/State.gd"

func _on_enter(params := {}):
	set_control_children_visible(true)
	._on_enter(params)

func _on_exit(passthrough_params := {}) -> Dictionary:
	set_control_children_visible(false)
	return ._on_exit(passthrough_params)

func set_control_children_visible(value: bool):
	for child in get_children():
		if child is Control:
			child.visible = value
