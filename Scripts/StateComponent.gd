class_name StateComponent
extends Node

signal is_active_changed(value)

var is_active := false
var was_is_active_ever_set := false

func set_is_active(value: bool):
	if was_is_active_ever_set and value == is_active:
		return
	is_active = value
	_on_is_active_changed(is_active)

func _on_is_active_changed(value: bool):
	Utils.set_all_process_callbacks_enabled(self, value)
	emit_signal("is_active_changed", value)
