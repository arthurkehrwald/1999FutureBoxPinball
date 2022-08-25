class_name ObjectiveHudMissionComplete
extends "res://Scripts/ObjectiveHudSubState.gd"

func _on_enter(params := {}):
	._on_enter(params)
	# In case this scripts mission tracker component has not yet been updated
	yield(get_tree(), "idle_frame")
	if MissionTracker.last_completed_mission:
		_play_mission_complete_animation(MissionTracker.last_completed_mission)
		animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

func _on_exit(passthrough_params := {}) -> Dictionary:
	animation_player.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.stop()
	return ._on_exit(passthrough_params)

func _play_mission_complete_animation(mission: Mission):
	objective_checkbox.pressed = false
	objective_checkbox.text = mission.objective
	message_label.text = "Objective Complete!"
	animation_player.play("objective_complete_anim")

func _on_AnimationPlayer_animation_finished(_animation_name: String):
	exit()
