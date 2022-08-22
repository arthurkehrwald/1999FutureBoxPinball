class_name Pregame
extends "res://Scripts/State.gd"

signal finished

export var path_to_player_ship := NodePath()
export var path_to_video_player := NodePath()
export var path_to_transmission_hud := NodePath()

onready var player_ship := get_node(path_to_player_ship) as PlayerShip
onready var video_player := get_node(path_to_video_player) as FullscreenVideoPlayer
onready var transmission_hud := get_node(path_to_transmission_hud) as TransmissionHud

func enter():
	.enter()
	Announcer.say("begin", true)
	video_player.play_pregame_video()
	video_player.connect("playback_finished", self, "_on_VideoPlayer_playback_finished")
	player_ship.set_is_vulnerable(false)
	transmission_hud.set_rex_mood(transmission_hud.RexMood.ANGRY)

func exit():
	.exit()
	player_ship.set_is_vulnerable(true)

func _on_VideoPlayer_playback_finished():
	emit_signal("finished")
