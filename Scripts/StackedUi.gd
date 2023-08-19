class_name StackedUi
extends "res://Scripts/UiState.gd"

var wants_focus := false setget set_wants_focus


signal wants_focus_changed(value)

func set_wants_focus(value: bool):
	if value == wants_focus:
		return
	wants_focus = value
	emit_signal("wants_focus_changed", wants_focus)
