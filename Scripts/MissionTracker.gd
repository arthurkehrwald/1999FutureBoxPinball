extends Node

signal mission_entered(mission)
signal mission_exited(mission, exit_params)

var current_mission: Mission = null setget _set_current_mission

# TODO: Doesn't work if missions are created after this. Replace with register/unregister pattern.
func _ready():
	for mission in get_tree().get_nodes_in_group("missions"):
		if mission is Mission:
			mission.connect("entered", self, "_on_Mission_entered", [mission])
			mission.connect("exited", self, "_on_Mission_exited", [mission])

func _on_Mission_entered(mission: Mission):
	_set_current_mission(mission)
	emit_signal("mission_entered", mission)

func _on_Mission_exited(exit_params: Dictionary, mission: Mission):
	if mission == current_mission:
		_set_current_mission(null)
	emit_signal("mission_exited", mission, exit_params)

func _set_current_mission(value: Mission):
	if value == current_mission:
		return
	current_mission = value
