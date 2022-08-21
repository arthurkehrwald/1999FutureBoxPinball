class_name Mission
extends "res://Scripts/State.gd"

signal completed
signal failed

export var time_limit_seconds: float = 30.0
export var objective: String = "Objective"

var time_remaining : float = 0.0

func enter():
	.enter()
	time_remaining = time_limit_seconds

func _process(delta):
	time_remaining -= delta
	if time_remaining <= 0.0:
		_on_mission_failed()

func _on_mission_completed():
	emit_signal("completed")

func _on_mission_failed():
	emit_signal("failed")
