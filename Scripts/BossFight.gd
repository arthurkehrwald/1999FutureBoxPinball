class_name BossFight
extends "res://Scripts/Mission.gd"

export var path_to_boss := NodePath()

onready var boss := get_node(path_to_boss) as Boss

func _on_enter(params := {}):
	._on_enter(params)
	boss.set_is_active(true)

func _on_exit(passthrough_params := {}) -> Dictionary:
	boss.set_is_active(false)
	return ._on_exit(passthrough_params)

func _ready():
	boss.connect("death", self, "_on_Boss_death")

func _on_Boss_death():
	_on_mission_completed()
