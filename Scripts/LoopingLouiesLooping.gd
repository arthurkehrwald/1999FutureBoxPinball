extends "res://Scripts/PseudoPhysicsPathFollow.gd"

export var progress_required_to_trigger_louie = .5

signal louie_triggered

var louie_active = false

func _enter_tree():
	GameState.connect("exposition_began", self, "reset", [false])
	GameState.connect("bossfight_began", self, "reset", [true])

func _physics_process(_delta):
	if !louie_active and (looping_body_entered_status == states.AT_ENTRANCE and get_unit_offset() > progress_required_to_trigger_louie) or (looping_body_entered_status == states.AT_EXIT and get_unit_offset() < progress_required_to_trigger_louie):
		emit_signal("louie_triggered")
		louie_active = true

func _on_LoopingLouie_landed():
	louie_active = false
