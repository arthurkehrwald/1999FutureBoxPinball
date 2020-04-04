class_name MoonGateSmallState
extends "res://Scripts/State.gd"

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self
	moon_gate.set_visible(false)


func handle_input(var input, var _opt_info = null):
	match input:
		_state_machine.In.DAMAGED:
			_state_machine.transition_to("ScalingUpState")


func exit():
	moon_gate.set_visible(true)
