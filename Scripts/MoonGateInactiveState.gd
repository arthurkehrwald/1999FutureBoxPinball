class_name MoonGateInactiveState
extends "res://Scripts/State.gd"
# Does absolutely nothing except transition into the damageable state.

onready var _moon_gate = get_node("../..")


func _handle_input(input, info = {}):
	match input:
		_state_machine.In.BOSS_FIGHT_BEGAN:
			_state_machine.transition_to("DamageableState")
