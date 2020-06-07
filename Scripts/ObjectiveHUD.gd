extends Control

var queued_new_objectives = []
var queued_complete_objectives = []
var is_new_objectives_anim_running = false

onready var animation_player = get_node("AnimationPlayer")
onready var objective_complete_label = get_node("ObjectiveCompleteLabel")
onready var objective_one_check_box = get_node("ObjectiveOneCheckBox")
onready var objective_two_check_box = get_node("ObjectiveTwoCheckBox")
onready var glitch_overlay = get_node("../GlitchOverlay")


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	GameState.connect("objective_one_completed", self, "set_objective_complete", [1])
	GameState.connect("objective_two_completed", self, "set_objective_complete", [2])
	GameState.connect("objectives_changed", self, "set_objectives")
	animation_player.connect("animation_finished", self, "on_anim_finished")
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("visibility_changed", self, "update_visibility")
	else:
		push_warning("[ObjectiveHUD] Can't find powerup roulette! Will ignore whether"
				+ " it is active or not.")
	if Globals.warning_hud != null:
		Globals.warning_hud.connect("visibility_changed", self, "update_visibility")
	else:
		push_warning("[ObjectiveHUD] Can't find warning hud! Will ignore whether"
				+ " it is active or not.")


func set_objectives(objectives):
	if not visible or animation_player.is_playing():
		queued_new_objectives.clear()
		queued_new_objectives.push_back(objectives[0])
		queued_new_objectives.push_back(objectives[1])
		return
	glitch_overlay.super_glitch()
	objective_one_check_box.text = objectives[0]
	objective_one_check_box.pressed = false
	objective_one_check_box.visible = objectives[0] != ""
	objective_two_check_box.text = objectives[1]
	objective_two_check_box.pressed = objectives[1] == ""
	objective_two_check_box.visible = objectives[1] != ""
	if not(objectives[0] == "" and objectives[1] == ""):
		objective_complete_label.text = "New Objective!"
		animation_player.play_backwards("objectives_complete_anim")
		is_new_objectives_anim_running = true


func set_objective_complete(completed_obj_index):
	if not visible or animation_player.is_playing():
		if not queued_complete_objectives.has(completed_obj_index):
			queued_complete_objectives.push_back(completed_obj_index)
		return
	glitch_overlay.super_glitch()
	match completed_obj_index:
		1:
			objective_one_check_box.pressed = true
			animation_player.play("objective_one_complete")
		2:
			objective_two_check_box.pressed = true
			animation_player.play("objective_two_complete")
	if objective_one_check_box.pressed and objective_two_check_box.pressed:
		yield(animation_player, "animation_finished")
		objective_complete_label.text = "Objective Complete!"
		animation_player.play("objectives_complete_anim")


func update_visibility():
	var is_other_ui_active = false
	if Globals.powerup_roulette != null and Globals.powerup_roulette.visible:
		is_other_ui_active = true
	if Globals.warning_hud != null and Globals.warning_hud.visible:
		is_other_ui_active = true
	visible = not is_other_ui_active
	if is_other_ui_active:
		animation_player.stop()
		is_new_objectives_anim_running = false
	elif not animation_player.is_playing():
		pop_queue()


func on_anim_finished(anim_name):
	if visible and anim_name == "objectives_complete_anim":
		if is_new_objectives_anim_running:
			is_new_objectives_anim_running = false
			queued_new_objectives.clear()
		pop_queue()
	else:
		queued_complete_objectives.pop_back()
		print(anim_name)


func pop_queue():
	if not queued_complete_objectives.empty():
		set_objective_complete(queued_complete_objectives.back())
	elif not queued_new_objectives.empty():
		set_objectives(queued_new_objectives)


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.PREGAME or is_debug_skip:
		queued_complete_objectives.clear()
		queued_new_objectives.clear()
		is_new_objectives_anim_running = false
		animation_player.stop()
