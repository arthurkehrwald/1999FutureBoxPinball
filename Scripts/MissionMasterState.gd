class_name MissionMasterState
extends "res://Scripts/State.gd"

signal missions_completed

export var mission_count: int = 3

var remaining_missions: int = 0

func enter():
	.enter()
	remaining_missions = mission_count
	_pick_random_mission()

func set_active_sub_state(value: State):
	assert(value is MissionState)
	assert(active_sub_state is MissionState || active_sub_state == null)
	var prev_mission := active_sub_state as MissionState
	.set_active_sub_state(value)
	assert(active_sub_state is MissionState)
	active_sub_state = active_sub_state as MissionState	
	if prev_mission != active_sub_state:
		if prev_mission:
			prev_mission.disconnect("completed", self, "_on_Mission_completed")
			prev_mission.disconnect("failed", self, "_on_Mission_failed")
		active_sub_state.connect("completed", self, "_on_Mission_completed")
		active_sub_state.connect("failed", self, "_on_Mission_failed")
	print("New objective %s" % active_sub_state.objective)

func _ready():
	for state in sub_states:
		assert(state is MissionState)

func _pick_random_mission():
	var sub_state_index = randi() % len(sub_states)
	var sub_state = sub_states[sub_state_index]
	set_active_sub_state(sub_state)

func _on_Mission_completed():
	print("Mission completed")
	remaining_missions -= 1
	if remaining_missions > 0:
		_pick_random_mission()
	else:
		emit_signal("missions_completed")

func _on_Mission_failed():
	print("Mission failed")
	_pick_random_mission()
