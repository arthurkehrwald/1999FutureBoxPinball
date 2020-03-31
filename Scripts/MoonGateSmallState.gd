extends Spatial

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self
	moon_gate.set_visible(false)


func handle_input(var input, var _opt_info = null):
	match input:
		moon_gate.In.DAMAGED:
			exit()
			moon_gate.get_node("ScaleStates/ScalingUp").enter()


func exit():
	moon_gate.set_visible(true)
