class_name CentralUi
extends "res://Scripts/StackedUiMaster.gd"

func _on_enter(params := {}):
	for state in sub_states:
		if not state.is_connected("entered", self, "_on_SubState_entered"):
			state.connect("entered", self, "_on_SubState_entered")
	._on_enter(params)

func _on_exit(params := {}):
	for state in sub_states:
		if state.is_connected("entered", self, "_on_SubState_entered"):
			state.disconnect("entered", self, "_on_SubState_entered")
	return ._on_exit(params)
