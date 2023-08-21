class_name BreakState
extends "res://Scripts/State.gd"

export var time := 5.0
export var timer_path := NodePath()
onready var timer := get_node(timer_path) as Timer

func _ready():
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.one_shot = true

func _on_enter(params := {}):
	timer.start(time)
	._on_enter()

func _on_exit(params := {}) -> Dictionary:
	timer.stop()
	return ._on_exit(params)

func _on_Timer_timeout():
	if is_active:
		exit()
