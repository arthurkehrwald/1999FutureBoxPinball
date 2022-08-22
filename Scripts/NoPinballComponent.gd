extends "res://Scripts/StateComponent.gd"


func set_is_active(value: bool):
	if value == is_active:
		return
	.set_is_active(value)
	# TODO implement
