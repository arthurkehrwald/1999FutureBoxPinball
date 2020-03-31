extends Spatial

onready var moon_gate = get_node("../..")

func enter():
	moon_gate.movement_state = self
	moon_gate.get_node("AnimationPlayer").play("moon_fly", -1, moon_gate.FLIGHT_DURATION)


func handle_input(var input, var _opt_info = null):
	match input:
		moon_gate.In.FLY_ANIM_DONE:
			exit()
			moon_gate.get_node("MovementStates/Stationary").enter()


func exit():
	pass
