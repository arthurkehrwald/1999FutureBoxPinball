class_name SoundEffectComponent
extends "res://Scripts/StateComponent.gd"

export var audio_player_path := NodePath()
onready var audio_player := get_node(audio_player_path) as AudioStreamPlayer

func _on_is_active_changed(value: bool):
	if value:
		audio_player.play()
