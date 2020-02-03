extends "res://Scripts/PseudoPhysicsPathFollow.gd"

export var progress_required_to_trigger_louie = .5

signal louie_triggered

var louie_active = false

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _physics_process(_delta):
	if !louie_active and (looping_body_entered_status == states.AT_ENTRANCE and get_unit_offset() > progress_required_to_trigger_louie) or (looping_body_entered_status == states.AT_EXIT and get_unit_offset() < progress_required_to_trigger_louie):
		emit_signal("louie_triggered")
		louie_active = true
		
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		reset(true)
	
func _on_LoopingLouie_landed():
	louie_active = false
