class_name StateComponent
extends Node

signal is_active_changed(value)

var is_active := false

func set_is_active(value: bool):
	if value == is_active:
		return
	is_active = value
	Utils.set_all_process_callbacks_enabled(self, is_active)
	emit_signal("is_active_changed", is_active)
