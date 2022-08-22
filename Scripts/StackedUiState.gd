class_name StackedUiState
extends "res://Scripts/State.gd"

export var path_to_active_state := NodePath()
export var path_to_inactive_state := NodePath()

onready var active_state := get_node(path_to_active_state) as State
onready var inactive_state := get_node(path_to_inactive_state) as State

var is_ui_active := false setget set_is_ui_active

func set_is_ui_active(value: bool):
	if value == is_ui_active:
		return
	.set_active_sub_state(active_state if is_ui_active else inactive_state)
