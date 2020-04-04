class_name MoonGateNotSpinningState
extends "res://Scripts/State.gd"

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self


func handle_input(var input, var opt_info = null):
	match input:
		moon_gate.In.HIT_BY_PROJECTILE:
			assert(opt_info != null)
			exit()
			moon_gate.get_node("SpinStates/Spinning").enter(opt_info)


func exit():
	pass
