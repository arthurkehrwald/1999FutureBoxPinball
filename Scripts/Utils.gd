extends Node

func set_all_process_callbacks_enabled(target: Node, value: bool):
	target.set_process(value)
	target.set_physics_process(value)
	target.set_process_input(value)
	target.set_process_unhandled_input(value)
	target.set_process_unhandled_key_input(value)
