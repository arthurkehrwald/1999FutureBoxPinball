class_name ObjectiveHudDisplayMission
extends "res://Scripts/UiState.gd"

export var path_to_checkbox := NodePath()
export var path_to_objective_label := NodePath()

var mission: Mission = null

onready var checkbox := get_node(path_to_checkbox) as CheckBox
onready var objective_label := get_node(path_to_objective_label) as RichTextLabel

func _on_enter(params := {}):
	mission = params["mission"] as Mission
	if mission:
		mission.connect("exited", self, "_on_Mission_exited")
		_start_display_mission()
	._on_enter(params)

func _on_exit(passthrough_params := {}):
	if mission and mission.is_connected("exited", self, "_on_Mission_exited"):
		mission.disconnect("exited", self, "_on_Mission_exited")
	._on_exit(passthrough_params)

func _start_display_mission():
	checkbox.pressed = mission.is_complete
	objective_label.text = mission.objective

func _on_Mission_exited(exit_params := {}):
	if !exit_params.has("is_complete"):
		return
	var is_complete := exit_params["is_complete"] as bool
	if is_complete != null:
		checkbox.pressed = is_complete
