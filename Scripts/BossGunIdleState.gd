extends Spatial

onready var boss_gun = get_node("..")
onready var shooting_state = get_node("../ShootingState")
onready var stunned_state = get_node("../StunnedState")

func enter():
	pass

func handle_input(var input, var _input_strength = NAN):
	if input == boss_gun.In.BOSS_SHOOT_COMMAND:
		exit()
		boss_gun.state = get_node("../ShootingState")
		shooting_state.enter()


func exit():
	pass
