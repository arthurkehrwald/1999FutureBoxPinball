class_name GameState
extends "res://Scripts/State.gd"

export var path_to_pregame := NodePath()
export var path_to_game_over := NodePath()
export var path_to_missions := NodePath()
export var path_to_bossfight := NodePath()
export var path_to_player_ship := NodePath()

onready var pregame := get_node(path_to_pregame) as Pregame
onready var missions := get_node(path_to_missions) as MissionMasterState
onready var boss_fight := get_node(path_to_bossfight) as BossFight
onready var game_over := get_node(path_to_game_over) as GameOver
onready var player_ship := get_node(path_to_player_ship) as PlayerShip

func enter(params := {}):
	.enter()
	pregame.connect("finished", self, "_on_Pregame_finished")
	missions.connect("missions_completed", self, "_on_Missions_completed")
	player_ship.connect("death", self, "_on_PlayerShip_death")
	set_active_sub_state(pregame)

func _on_Pregame_finished():
	set_active_sub_state(missions)

func _on_Missions_completed():
	set_active_sub_state(boss_fight)

func _on_ActiveSubState_exited(params := {}):
	match active_sub_state:
		boss_fight:
			set_active_sub_state(missions)
		_:
			._on_ActiveSubState_exited()

func _on_PlayerShip_death():
	set_active_sub_state(game_over)

func _on_GameOver_finished():
	get_tree().reload_current_scene()
