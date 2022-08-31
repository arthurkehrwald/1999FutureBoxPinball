class_name ObjectiveHud
extends "res://Scripts/StackedUi.gd"

export var path_to_new_mission_state := NodePath()
export var path_to_mission_display_state := NodePath()
export var path_to_mission_complete_state := NodePath()
export var path_to_mission_failed_state := NodePath()

onready var new_mission_state := get_node(path_to_new_mission_state) as State
onready var mission_display_state := get_node(path_to_mission_display_state) as ObjectiveHudDisplayMission
onready var mission_complete_state := get_node(path_to_mission_complete_state) as State
onready var mission_failed_state := get_node(path_to_mission_failed_state) as State

var current_mission: Mission = null
var queued_new_mission: Mission = null
var queued_completed_mission: Mission = null

func _on_enter(params := {}):
	._on_enter(params)
	if not handle_queued_missions():
		set_wants_focus(false)

func handle_queued_missions() -> bool:
	if queued_completed_mission:
		queued_completed_mission = null
		set_active_sub_state(mission_complete_state)
		return true
	if queued_new_mission and queued_new_mission == MissionTracker.current_mission:
		queued_new_mission = null
		set_active_sub_state(new_mission_state)
		return true
	return false

func _on_ActiveSubState_exited(_exit_params := {}):
	if active_sub_state == new_mission_state:
		set_active_sub_state(mission_display_state, {"mission": MissionTracker.current_mission})
	elif [mission_complete_state, mission_failed_state].has(active_sub_state):
		if not handle_queued_missions():
			._on_ActiveSubState_exited()
			set_wants_focus(false)
	else:
		._on_ActiveSubState_exited()

func _on_MissionTracker_mission_entered(mission: Mission):
	if is_active and [null, new_mission_state, mission_display_state].has(active_sub_state):
		current_mission = mission
		set_active_sub_state(new_mission_state)
	else:
		queued_new_mission = mission
		set_wants_focus(true)

func _on_MissionTracker_mission_exited(mission: Mission, exit_params: Dictionary):
	if mission != current_mission:
		return
	if is_active:
		current_mission = null
		if exit_params["is_complete"]:
			set_active_sub_state(mission_complete_state)
		else:
			set_active_sub_state(mission_failed_state)
	else:
		queued_completed_mission = mission

func _ready():
	MissionTracker.connect("mission_entered", self, "_on_MissionTracker_mission_entered")
	MissionTracker.connect("mission_exited", self, "_on_MissionTracker_mission_exited")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		set_active_sub_state(new_mission_state)
