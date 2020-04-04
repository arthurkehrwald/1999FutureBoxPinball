extends "res://Scripts/DamageableState.gd"


func _handle_input(var input, var info = {}):
	._handle_input(input, info)
	match input:
		_state_machine.In.DEATH:
			_state_machine.transition_to("FlyingState")
