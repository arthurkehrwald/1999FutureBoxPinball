class_name MusicComponent
extends "res://Scripts/StateComponent.gd"

export var stream: AudioStream = null

func _enter_tree():
	add_to_group("music_component")
