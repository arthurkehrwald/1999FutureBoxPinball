class_name GameOver
extends "res://Scripts/State.gd"

export var path_to_player_ship := NodePath()
onready var player_ship := get_node(path_to_player_ship) as PlayerShip

export var path_to_video_player := NodePath()
onready var video_player := get_node(path_to_video_player) as FullscreenVideoPlayer

func enter():
	.enter()
	Announcer.say("sux", true)
	video_player.play_game_over_video()
	player_ship.set_is_vulnerable(false)

func exit():
	.exit()
	player_ship.set_is_vulnerable(true)
