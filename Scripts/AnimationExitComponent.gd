class_name AnimationExitComponent
extends "res://Scripts/ExitComponent.gd"

export var path_to_animation_player := NodePath()
export var animation_name: String

onready var animation_player := get_node(path_to_animation_player) as AnimationPlayer

func _on_is_active_changed(value: bool):
	if value:
		if !animation_player.is_connected("animation_finished", self, "_on_AnimationPlayer_finished"):
			animation_player.connect("animation_finished", self, "_on_AnimationPlayer_finished")
		animation_player.advance(0.0)
		animation_player.play(animation_name)
	else:
		if animation_player.is_connected("animation_finished", self, "_on_AnimationPlayer_finished"):
			animation_player.disconnect("animation_finished", self, "_on_AnimationPlayer_finished")
		animation_player.stop(true)
	._on_is_active_changed(value)

func _on_AnimationPlayer_finished(_animation_name: String):
	emit_signal("exit_condition_met")
