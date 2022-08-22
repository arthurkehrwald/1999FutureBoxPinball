extends Control

var queued_new_objective := ""
var is_objective_complete_anim_queued := false
var is_new_objectives_anim_running := false

onready var animation_player = get_node("AnimationPlayer")
onready var objective_complete_label = get_node("ObjectiveCompleteLabel")
onready var objective_checkbox = get_node("ObjectiveOneCheckBox")
onready var glitch_overlay = get_node("../GlitchOverlay")


func _ready():
	for mission in get_tree().get_nodes_in_group("missions"):
		if mission is Mission:
			mission.connect("entered", self, "_on_Mission_entered", [mission])
			mission.connect("exited", self, "_on_Mission_exited", [mission])
			mission.connect("completed", self, "_on_Mission_completed", [mission])
			mission.connect("failed", self, "_on_Mission_failed", [mission])
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

func _on_Mission_entered(mission: Mission):
	set_objective(mission.objective)

func _on_Mission_exited(mission: Mission):
	set_objective("")

func _on_Mission_completed(mission: Mission):
	set_objective_complete()

func _on_Mission_failed(mission: Mission):
	pass

func set_objective(objective: String):
	if not visible or animation_player.is_playing():
		queued_new_objective = ""
		queued_new_objective = objective
		return
	glitch_overlay.super_glitch()
	objective_checkbox.text = objective
	objective_checkbox.pressed = false
	objective_checkbox.visible = objective != ""
	if objective != "":
		objective_complete_label.text = "New Objective!"
		animation_player.play_backwards("objective_complete_anim")
		is_new_objectives_anim_running = true


func set_objective_complete():
	if not visible or animation_player.is_playing():
		is_objective_complete_anim_queued = true
		return
	glitch_overlay.super_glitch()
	objective_checkbox.pressed = true
	yield(animation_player, "animation_finished")
	objective_complete_label.text = "Objective Complete!"
	animation_player.play("objective_complete_anim")


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
	if visible and anim_name == "objective_complete_anim":
		if is_new_objectives_anim_running:
			is_new_objectives_anim_running = false
			queued_new_objective = ""
		pop_queue()


func pop_queue():
	if is_objective_complete_anim_queued:
		set_objective_complete()
	elif queued_new_objective != "":
		set_objective(queued_new_objective)
