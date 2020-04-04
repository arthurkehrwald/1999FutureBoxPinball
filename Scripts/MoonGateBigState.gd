class_name MoonGateBigState
extends "res://Scripts/State.gd"

onready var moon_gate = get_node("../..")
onready var _general_state_machine = get_node("..")

func enter():
	moon_gate.movement_state = self


func handle_input(var input, var _opt_info = null):
	match input:
		moon_gate.In.FLY_ANIM_DONE:
			if moon_gate.spin_state == moon_gate.get_node("SpinStates/Spinning"):
				exit()
				moon_gate.get_node("ScaleStates/ScalingDown").enter()
		moon_gate.In.STOPPED_SPINNING:
			if moon_gate.movement_state == moon_gate.get_node("MovementStates/Stationary"):
				exit()
				moon_gate.get_node("ScaleStates/ScalingDown")


func exit():
	pass
