extends Control

var is_active = true

onready var animation_player = get_node("AnimationPlayer")
onready var objective_complete_label = get_node("ObjectiveCompleteLabel")
onready var objective_one_check_box = get_node("ObjectiveOneCheckBox")
onready var objective_two_check_box = get_node("ObjectiveTwoCheckBox")
onready var glitch_overlay = get_node("../GlitchOverlay")


func _ready():
	GameState.connect("objective_one_completed", self, "set_objective_complete", [1])
	GameState.connect("objective_two_completed", self, "set_objective_complete", [2])
	GameState.connect("objectives_changed", self, "set_objectives")
	if Globals.shop_menu != null:
		Globals.shop_menu.connect("is_active_changed", self, "on_ShopMenu_is_active_changed")
	else:
		push_warning("[ObjectiveHUD] Can't find shop menu! Will ignore whether"
				+ " it is active or not.")


func set_objectives(objectives):
	if Globals.shop_menu != null and Globals.shop_menu.is_active:
		yield(Globals.shop_menu, "is_active_changed")
	if animation_player.is_playing():
		yield(animation_player, "animation_finished")
	if objectives[0] == "" and objectives[1] == "":
		set_visible(false)
		return
	set_visible(true)
	glitch_overlay.super_glitch()
	objective_one_check_box.text = objectives[0]
	objective_one_check_box.pressed = false
	objective_one_check_box.visible = objectives[0] != ""
	objective_two_check_box.text = objectives[1]
	objective_two_check_box.pressed = objectives[1] == ""
	objective_two_check_box.visible = objectives[1] != ""
	objective_complete_label.text = "New Objectives!"
	animation_player.play_backwards("objectives_complete_anim")


func set_objective_complete(completed_obj_index):
	if Globals.shop_menu != null and Globals.shop_menu.is_active:
		yield(Globals.shop_menu, "is_active_changed")
	if animation_player.is_playing():
		yield(animation_player, "animation_finished")
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
		objective_complete_label.text = "Complete!"
		animation_player.play("objectives_complete_anim")


func on_ShopMenu_is_active_changed(value):
	set_visible(!value)
