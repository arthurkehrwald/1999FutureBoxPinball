class_name GameOver
extends "res://Scripts/State.gd"

export var path_to_player_ship := NodePath()
onready var player_ship := get_node(path_to_player_ship) as PlayerShip

export var path_to_video_player := NodePath()
onready var video_player := get_node(path_to_video_player) as FullscreenVideoPlayer

func _on_enter(params := {}):
	._on_enter(params)
	Announcer.say("sux", true)
	video_player.play_game_over_video()
	if not video_player.is_connected("playback_finished", self, "_on_VideoPlayer_playback_finished"):
		video_player.connect("playback_finished", self, "_on_VideoPlayer_playback_finished")
	player_ship.set_is_vulnerable(false)

func _on_exit(passthrough_params := {}) -> Dictionary:
	if video_player.is_connected("playback_finished", self, "_on_VideoPlayer_playback_finished"):
		video_player.disconnect("playback_finished", self, "_on_VideoPlayer_playback_finished")
	player_ship.set_is_vulnerable(true)
	return ._on_exit(passthrough_params)

func _on_VideoPlayer_playback_finished():
	exit()
