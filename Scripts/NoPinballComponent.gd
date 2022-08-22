class_name NoPinballComponent
extends "res://Scripts/StateComponent.gd"


func set_is_active(value: bool):
	if value == is_active:
		return
	.set_is_active(value)
	get_tree().call_group("pinball_spawns", "set_is_active", !is_active)
	get_tree().call_group("plungers", "set_is_active", !is_active)
	get_tree().call_group("flippers", "set_is_active", !is_active)
