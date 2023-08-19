class_name StackedUiMaster
extends "res://Scripts/UiState.gd"

func _on_enter(params := {}):
	for state in sub_states:
		if state is StackedUi:
			state.connect("wants_focus_changed", self, "_on_SubState_wants_focus_changed")
	evaluate_focus()
	._on_enter(params)

func _on_exit(passthrough_params := {}) -> Dictionary:
	for state in sub_states:
		if state is StackedUi:
			if state.is_connected("wants_focus_changed", self, "_on_SubState_wants_focus_changed"):
				state.disconnect("wants_focus_changed", self, "_on_SubState_wants_focus_changed")
	return ._on_exit(passthrough_params)

func _on_SubState_wants_focus_changed(_value: bool):
	evaluate_focus()

func evaluate_focus():
	for state in sub_states:
		if state is StackedUi and state.wants_focus:
			if not state.is_active:
				set_active_sub_state(state)
			return
