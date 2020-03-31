extends Spatial

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self


func handle_input(var input, var opt_info = null):
	match input:
		moon_gate.In.IMPACT:
			assert(opt_info != null)
			exit()
			moon_gate.get_node("SpinStates/Spinning").enter(opt_info)


func exit():
	pass
