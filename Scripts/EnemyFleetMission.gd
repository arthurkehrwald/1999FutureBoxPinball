class_name EnemyFleetMission
extends "res://Scripts/Mission.gd"

export var path_to_enemy_fleet := NodePath()

onready var enemy_fleet := get_node(path_to_enemy_fleet) as EnemyFleet

func _on_enter(params := {}):
	enemy_fleet.set_is_active(true)
	enemy_fleet.connect("defeated", self, "_on_EnemyFleet_defeated")
	._on_enter(params)

func _on_exit(passthrough_params := {}) -> Dictionary:
	enemy_fleet.set_is_active(false)
	enemy_fleet.disconnect("defeated", self, "_on_EnemyFleet_defeated")
	return ._on_exit(passthrough_params)

func _on_EnemyFleet_defeated():
	_on_mission_completed()
