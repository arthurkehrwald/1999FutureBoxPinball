class_name ObjectiveHudNewMission
extends "res://Scripts/ObjectiveHudSubState.gd"

func _on_enter():
	._on_enter()
	# In case this scripts mission tracker component has not yet been updated
	yield(get_tree(), "idle_frame")	
	if MissionTracker.current_mission:
		_play_intro_animation(MissionTracker.current_mission)
		animation_player.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")

func _on_exit():
	._on_exit()
	animation_player.disconnect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	animation_player.stop()

func _play_intro_animation(mission: Mission):
	objective_checkbox.text = mission.objective
	objective_checkbox.pressed = false
	message_label.text = "New Objective!"
	animation_player.play_backwards("objective_complete_anim")

func _on_AnimationPlayer_animation_finished(_animation_name: String):
	exit()
