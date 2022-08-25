class_name ObjectiveHudNewMission
extends "res://Scripts/ObjectiveHudSubState.gd"

func _on_enter(params := {}):
	._on_enter(params)
	# In case this scripts mission tracker component has not yet been updated
	yield(get_tree(), "idle_frame")	
	if MissionTracker.current_mission:
		_play_intro_animation(MissionTracker.current_mission)
		animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

func _on_exit(passthrough_params := {}) -> Dictionary:
	animation_player.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.stop()
	return ._on_exit(passthrough_params)

func _play_intro_animation(mission: Mission):
	objective_checkbox.text = mission.objective
	objective_checkbox.pressed = false
	message_label.text = "New Objective!"
	animation_player.play_backwards("objective_complete_anim")

func _on_AnimationPlayer_animation_finished(_animation_name: String):
	exit()
