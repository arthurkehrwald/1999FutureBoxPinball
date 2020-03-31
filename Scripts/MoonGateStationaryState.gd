extends Spatial

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self


func handle_input(var input, var _opt_info = null):
	match input:
		moon_gate.In.DEATH:
			exit()
			moon_gate.get_node("MovementStates/Flying").enter()


func exit():
	pass
