class_name ObjectiveHudState
extends "res://Scripts/State.gd"

export var path_to_new_mission_state := NodePath()
export var path_to_mission_display_state := NodePath()
export var path_to_mission_complete_state := NodePath()
export var path_to_mission_tracker := NodePath()

onready var new_mission_state := get_node(path_to_new_mission_state) as ObjectiveHudNewMission
onready var mission_display_state := get_node(path_to_mission_display_state) as ObjectiveHudDisplayMission
onready var mission_complete_state := get_node(path_to_mission_complete_state) as ObjectiveHudMissionComplete
onready var mission_tracker := get_node(path_to_mission_tracker) as CurrentMissionTracker

var queued_new_mission: Mission = null
var queued_completed_mission: Mission = null

func _on_enter():
	._on_enter()
	handle_queued_missions()

func handle_queued_missions() -> bool:
	if queued_completed_mission:
		queued_completed_mission = null
		.set_active_sub_state(mission_complete_state)
		return true
	if queued_new_mission and queued_new_mission == mission_tracker.current_mission:
		queued_new_mission = null
		.set_active_sub_state(new_mission_state)
		return true
	return false

func _on_ActiveSubState_exited():
	match active_sub_state:
		new_mission_state:
			.set_active_sub_state(mission_display_state)
		mission_complete_state:
			if not handle_queued_missions():
				._on_ActiveSubState_exited()
		_:
			._on_ActiveSubState_exited()

func _on_MissionTracker_current_mission_changed(mission: Mission):
	if is_active and not active_sub_state == mission_complete_state:
		.set_active_sub_state(new_mission_state)
	else:
		queued_new_mission = mission

func _on_MissionTracker_current_mission_completed(mission: Mission):
	if is_active:
		.set_active_sub_state(mission_complete_state)
	else:
		queued_completed_mission = mission

func _ready():
	mission_tracker.connect("current_mission_changed", self, "_on_MissionTracker_current_mission_changed")
	mission_tracker.connect("current_mission_completed", self,"_on_MissionTracker_current_mission_completed")
