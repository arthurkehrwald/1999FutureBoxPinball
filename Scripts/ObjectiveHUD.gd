extends Control

signal panel_changed

var had_objectives = false

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	GameState.connect("objective_one_completed", self, "set_objective_complete", [1])
	GameState.connect("objective_two_completed", self, "set_objective_complete", [2])
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	match new_stage:
		GameState.PREGAME:
			reset()
			turn_off()
		GameState.EXPOSITION:
			if is_debug_skip:
				reset()
				turn_off()
		GameState.ENEMY_FLEET:
			change_objective("Defeat the enemy fleet!", "Buy something at the shop!")
		GameState.BOSS_BEGIN:
			change_objective("Defeat the emperor!", "")
		GameState.ECLIPSE:
			if is_debug_skip:
				change_objective("Defeat the emperor!", "")

func set_objective_complete(completed_obj_index):
	if get_tree().paused:
		yield(GameState, "unpaused")
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
		
func reset():
	had_objectives = false
