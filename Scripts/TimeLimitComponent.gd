extends "res://Scripts/ExitComponent.gd"

export var time_limit_sec := 30.0
export var path_to_timer := NodePath()
onready var timer := get_node(path_to_timer) as Timer

func _on_is_active_changed(value: bool):
	if value:
		timer.start(time_limit_sec)
		timer.connect("timeout", self, "_on_Timer_timeout")
	else:
		timer.stop()
		timer.disconnect("timeout", self, "_on_Timer_timeout")
	._on_is_active_changed(value)

func _on_Timer_timeout():
	emit_signal("exit_condition_met")

func _ready():
	timer.one_shot = true
