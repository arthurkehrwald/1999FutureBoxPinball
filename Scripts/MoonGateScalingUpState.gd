class_name MoonGateScalingUpState
extends "res://Scripts/State.gd"

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self
	moon_gate.get_node("AnimationPlayer").play("moon_spectral_transition")


func handle_input(var input, var _opt_info = null):
	match input:
		moon_gate.In.SCALE_ANIM_DONE:
			exit()
			var is_flying = moon_gate.movement_state == moon_gate.get_node("MovementStates/Flying")
			var is_spinning = moon_gate.spinning_state == moon_gate.get_node("SpinningStates/Spinning")
			if is_flying or is_spinning:
				moon_gate.get_node("ScaleStates/Big").enter()
			else:
				moon_gate.get_node("ScaleStates/ScalingDown").enter()


func exit():
	pass
