class_name EnemyFleetMission
extends "res://Scripts/Mission.gd"

export var path_to_enemy_fleet := NodePath()
export var path_to_transmission_hud := NodePath()

onready var enemy_fleet := get_node(path_to_enemy_fleet) as EnemyFleet
onready var transmission_hud := get_node(path_to_transmission_hud) as TransmissionHud

func _on_enter():
	._on_enter()
	enemy_fleet.set_is_active(true)
	enemy_fleet.connect("defeated", self, "_on_EnemyFleet_defeated")
	transmission_hud.play_sequence(transmission_hud.SequenceId.ENEMY_FLEET)

func _on_exit():
	._on_exit()
	enemy_fleet.set_is_active(false)
	enemy_fleet.disconnect("defeated", self, "_on_EnemyFleet_defeated")

func _on_EnemyFleet_defeated():
	_on_mission_completed()
