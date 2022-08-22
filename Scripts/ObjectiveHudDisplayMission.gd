class_name ObjectiveHudDisplayMission
extends "res://Scripts/ObjectiveHudSubState.gd"

func _on_enter():
	._on_enter()
	# In case this scripts mission tracker component has not yet been updated
	yield(get_tree(), "idle_frame")
	if mission_tracker.current_mission:
		_start_display_mission(mission_tracker.current_mission)

func _start_display_mission(mission: Mission):
	objective_checkbox.pressed = false
	objective_checkbox.text = mission.objective	
