extends Control

signal panel_changed

var had_objectives = false

func _enter_tree():
	GameState.connect("global_reset", self, "reset")
	GameState.connect("pregame_began", self, "turn_off")
	GameState.connect("enemy_fleet_fight_began", self, "change_objective", ["Defeat the emperor's fleet!", "Buy something at the shop!"])
	GameState.connect("bossfight_began", self, "change_objective", ["Defeat the emperor!", ""])
	GameState.connect("objective_one_completed", self, "set_objective_complete", [1])
	GameState.connect("objective_two_completed", self, "set_objective_complete", [2])
	
func set_objective_complete(completed_obj_index):
	match completed_obj_index:
		1:
			$ObjectiveCheckBox1.pressed = true
			$AnimationPlayer.play("objective_one_complete")
		2:
			$ObjectiveCheckBox2.pressed = true
			$AnimationPlayer.play("objective_two_complete")
	
func change_objective(obj_one, obj_two):
	if $AnimationPlayer.is_playing():
		yield($AnimationPlayer, "animation_finished")
	if had_objectives:
		$ObjectiveCompleteLabel.text = "Complete!"
		$AnimationPlayer.play("objectives_complete_anim")
		yield($AnimationPlayer, "animation_finished")
	set_objectives(obj_one, obj_two)
	$ObjectiveCompleteLabel.text = "New Objectives!"
	$AnimationPlayer.play_backwards("objectives_complete_anim")

func set_objectives(obj_one, obj_two):
	set_visible(true)
	$ObjectiveCheckBox1.text = obj_one
	$ObjectiveCheckBox1.pressed = false
	$ObjectiveCheckBox2.text = obj_two
	$ObjectiveCheckBox2.pressed = false
	$ObjectiveCheckBox2.visible = obj_two != ""
	emit_signal("panel_changed")
		
func turn_off():
	set_visible(false)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
		
func reset(is_init):
	if !is_init:
		had_objectives = false
