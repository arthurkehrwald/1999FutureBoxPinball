class_name EnemyFleetMission
extends "res://Scripts/Mission.gd"

export var path_to_enemy_fleet: NodePath = NodePath()
onready var enemy_fleet := get_node(path_to_enemy_fleet) as EnemyFleet

func enter():
	.enter()
	#enemy_fleet.set_is_active(true)
	enemy_fleet.connect("defeated", self, "_on_EnemyFleet_defeated")

func exit():
	.exit()
	enemy_fleet.set_is_active(false)
	enemy_fleet.disconnect("defeated", self, "_on_EnemyFleet_defeated")

func _input(event):	
	if event.is_action_pressed("plunger"):
		enemy_fleet.set_is_active(true)


func _on_EnemyFleet_defeated():
	_on_mission_completed()
