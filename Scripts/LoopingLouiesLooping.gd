extends "res://Scripts/PseudoPhysicsPathFollow.gd"

export var progress_required_to_trigger_louie = .5

signal louie_triggered

var louie_active = false

func _physics_process(delta):
	if !louie_active and (looping_body_entered_at_entrance and get_unit_offset() > progress_required_to_trigger_louie) or (!looping_body_entered_at_entrance and get_unit_offset() < progress_required_to_trigger_louie):
		emit_signal("louie_triggered")
		louie_active = true

func _on_LoopingLouie_landed():
	louie_active = false
