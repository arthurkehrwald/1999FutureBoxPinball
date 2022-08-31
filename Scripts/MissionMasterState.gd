class_name MissionMasterState
extends "res://Scripts/State.gd"

export var mission_count: int = 3
export var path_to_initial_mission: NodePath = NodePath()

var remaining_missions: int = 0

func _on_enter(params := {}):
	._on_enter(params)
	remaining_missions = mission_count
	var first_mission = get_node(path_to_initial_mission) as Mission
	if first_mission:
		set_active_sub_state(first_mission)
	else:
		_pick_random_mission()
	Announcer.say("stage1", true)

func _on_exit(passthrough_params := {}) -> Dictionary:
	var params = {"is_complete:": remaining_missions == 0}
	params = Utils.merge_dict(passthrough_params, params)
	return ._on_exit(params)

func set_active_sub_state(value: State, enter_params := {}):
	assert(value is Mission || value == null)
	assert(active_sub_state is Mission || active_sub_state == null)
	.set_active_sub_state(value, enter_params)
	assert(active_sub_state is Mission)
	active_sub_state = active_sub_state as Mission

func _ready():
	for state in sub_states:
		assert(state is Mission)

func _pick_random_mission():
	var sub_state_index = randi() % len(sub_states)
	var sub_state = sub_states[sub_state_index]
	set_active_sub_state(sub_state)

func _on_ActiveSubState_exited(_params := {}):
	active_sub_state = active_sub_state as Mission
	if active_sub_state.is_complete:
		remaining_missions -= 1
		if remaining_missions > 0:
			_pick_random_mission()
		else:
			exit()
	else:
		_pick_random_mission()
