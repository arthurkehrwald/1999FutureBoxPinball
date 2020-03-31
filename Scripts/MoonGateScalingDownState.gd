extends Spatial

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self
	moon_gate.get_node("AnimationPlayer").play_backwards("moon_scale")

func handle_input(var input, var _opt_info = null):
	match input:
		moon_gate.In.SCALE_ANIM_DONE:
			exit()
			moon_gate.get_node("ScaleStates/Small").enter()


func exit():
	pass
