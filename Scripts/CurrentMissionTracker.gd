class_name CurrentMissionTracker
extends "res://Scripts/StateComponent.gd"

signal current_mission_changed(mission)
signal current_mission_completed(mission)

var current_mission: Mission = null setget _set_current_mission
var last_completed_mission: Mission = null

func _ready():
	for mission in get_tree().get_nodes_in_group("missions"):
		if mission is Mission:
			mission.connect("entered", self, "_on_Mission_entered", [mission])
			mission.connect("exited", self, "_on_Mission_exited", [mission])

func _on_Mission_entered(mission: Mission):
	_set_current_mission(mission)

func _on_Mission_exited(mission: Mission):
	if mission == current_mission:
		if mission.is_complete:
			last_completed_mission = mission
			emit_signal("current_mission_completed", mission)
		_set_current_mission(null)

func _set_current_mission(value: Mission):
	if value == current_mission:
		return
	current_mission = value
	emit_signal("current_mission_changed", current_mission)
