class_name AnimationComponent
extends "res://Scripts/StateComponent.gd"

export var path_to_animation_player := NodePath()
export var animation_name: String

onready var animation_player := get_node(path_to_animation_player) as AnimationPlayer

func _on_is_active_changed(value: bool):
	if value:
		animation_player.play(animation_name)
		animation_player.advance(0.0)
	else:
		animation_player.stop(true)
