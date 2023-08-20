class_name NoPinballComponent
extends "res://Scripts/StateComponent.gd"


func _on_is_active_changed(value: bool):
	if value:
		get_tree().call_group("pinballs", "queue_free")
	get_tree().call_group("pinball_spawns", "set_is_active", !is_active)
	get_tree().call_group("plungers", "set_is_active", !is_active)
	get_tree().call_group("flippers", "set_is_active", !is_active)
	._on_is_active_changed(value)
