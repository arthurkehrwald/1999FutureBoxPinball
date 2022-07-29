class_name PowerupRoulette
extends Control

enum State {
	INACTIVE,
	SPINNING,
	SELECTING,
	PRESENTING
}

const ICON_SCENE = preload("res://Scenes/PowerupIcon.tscn")
export(float) var time_to_present_selected_powerup := 5.0
export(bool) var do_display_powerup_name_while_spinning := false
export(float) var debug_spin_speed := 2.0
export(float) var debug_speed_decay := 1.0

var spin_speed := 0.0
var spin_speed_decay := 0.0
var state = State.INACTIVE
var unscaled_icon_width : float
var min_icon_pos_x : float
var max_icon_pos_x : float
var spin_progress := 0.0 setget set_spin_progress

var powerups := []
var powerup_icons := []
var selected_powerup : Powerup = null
var instruction_timers := []

onready var icon_parent = get_node("Icons")
onready var tween = get_node("Tween")
onready var glitch_overlay = get_node("../GlitchOverlay")
onready var instruction_rect = get_node("InstructionRect")
onready var name_label = get_node("NameLabel")
onready var time_bar = get_node("TimeBar")
onready var selected_icon_rect = get_node("SelectedIconRect")


func _enter_tree():
	Globals.powerup_roulette = self


func register_powerup(powerup : Powerup):
	if powerups.has(powerup):
		push_error("Powerup %s is already registered! Cannot register" % powerup.powerup_name)
		return
	powerups.push_back(powerup)


func unregister_powerup(powerup: Powerup):
	if !powerups.has(powerup):
		push_error("Powerup %s is not registered! Cannot unregister" % powerup.powerup_name)
		return
	powerups.erase(powerup)


func _ready():
	visible = false
	randomize()


func _input(event):
	if event.is_action("debug_spin_roulette"):
		start_spinning(debug_spin_speed, debug_speed_decay)


func _process(delta):
	if state == State.SPINNING:
		set_spin_progress(spin_progress + spin_speed * delta)
		spin_speed -= spin_speed_decay * delta
		if spin_speed < 0:
			select_center_icon()
	if state == State.PRESENTING:
		if selected_powerup.duration > 0.0:
			time_bar.value = selected_powerup.get_time_left()


func set_inactive():
	state = State.INACTIVE
	selected_powerup = null
	visible = false


func start_spinning(speed: float, decay: float):
	spin_speed = speed
	spin_speed_decay = decay
	if state == State.SPINNING:
		return
	state = State.SPINNING
	visible = true
	name_label.visible = do_display_powerup_name_while_spinning
	icon_parent.visible = true
	instruction_rect.visible = false
	time_bar.visible = false
	selected_icon_rect.visible = false
	prepare_powerup_icons()


func select_center_icon():
	state = State.SELECTING
	var selected_icon = get_center_icon()
	selected_powerup = selected_icon.associated_powerup
	trigger_selection_animation(selected_icon)
	selected_icon.connect("selection_animation_finished", self, "_on_PowerupIcon_selection_animation_finished", [], CONNECT_ONESHOT)


func _on_PowerupIcon_selection_animation_finished():
	if selected_powerup == null:
		return
	selected_powerup.activate()
	present_selected_powerup()


func present_selected_powerup():
	if selected_powerup == null:
		return
	state = State.PRESENTING
	name_label.visible = true
	name_label.text = selected_powerup.powerup_name
	if selected_powerup.duration > 0.0:
		time_bar.visible = true
		time_bar.max_value = selected_powerup.duration
		selected_powerup.connect("is_active_changed", self, "_on_SelectedPowerup_is_active_changed", [], CONNECT_ONESHOT)
	else:
		var timer = get_tree().create_timer(time_to_present_selected_powerup)
		timer.connect("timeout", self, "_on_PresentPowerupTimer_timeout")


func _on_PresentPowerupTimer_timeout():
	set_inactive()

func _on_SelectedPowerup_is_active_changed(value):
	if state == State.PRESENTING and !value:
		set_inactive()


func display_instructions(powerup: Powerup):
	state = State.INSTRUCTING
	selected_icon_rect.texture = powerup.icon
	name_label.text = powerup.powerup_name
	instruction_rect.texture = powerup.instructions
	name_label.visible = true
	icon_parent.visible = false
	selected_icon_rect.visible = true
	instruction_rect.visible = true
	if glitch_overlay != null:
		glitch_overlay.super_glitch()


func set_spin_progress(value: float):
	spin_progress = fmod(value, 1.0)
	var visible_icons = calc_icon_count_to_fill_icon_parent(unscaled_icon_width) + 1
	var progress_offset_between_icons = (1.0 / visible_icons)
	for i in range(0, powerup_icons.size()):
		var anim_progress = spin_progress + i * progress_offset_between_icons
		if anim_progress > 1.0:
			anim_progress = fmod(anim_progress, 1.0) 
			if anim_progress > spin_progress - progress_offset_between_icons + .01:
				anim_progress = 0
		powerup_icons[i].set_animation_progress(anim_progress)


func get_center_icon() -> PowerupRouletteIcon:
	var selected_icon = null
	var selected_icon_dist_to_middle = null
	for icon in powerup_icons:
		if selected_icon == null:
			selected_icon = icon
			selected_icon_dist_to_middle = selected_icon.calc_dist_to_middle()
		else:
			var icon_dist_to_middle = icon.calc_dist_to_middle()
			if icon_dist_to_middle < selected_icon_dist_to_middle:
				selected_icon = icon
				selected_icon_dist_to_middle = icon_dist_to_middle
	return selected_icon


func trigger_selection_animation(selected_icon: PowerupRouletteIcon):
	for icon in powerup_icons:
		icon = icon as PowerupRouletteIcon
		if icon == selected_icon:
			tween.interpolate_property(icon, "animation_progress",
					icon.animation_progress, 0.5,
					 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			icon.play_selection_animation()
		else:
			tween.interpolate_property(icon, "modulate",
					icon.modulate, Color(1, 1, 1, 0),
					 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.interpolate_property(icon, "rect_scale",
					icon.rect_scale, Vector2.ZERO,
					 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func has_at_least_one_viable_powerup() -> bool:
	for powerup in powerups:
		if powerup.probability > 0:
			return true
	return false


func _on_Shop_hit(speed: float, decay: float):
	if has_at_least_one_viable_powerup():
		start_spinning(speed, decay)


func prepare_powerup_icons():
	delete_powerup_icons()
	create_icons_for_all_powerups()
	if powerup_icons.empty():
		return
	unscaled_icon_width = powerup_icons[0].rect_size.x
	var min_icon_count = calc_icon_count_to_fill_icon_parent(unscaled_icon_width) + 1
	var created_enough_icons_to_fill_space = powerup_icons.size() >= min_icon_count
	while !created_enough_icons_to_fill_space:
		create_icons_for_all_powerups()
		created_enough_icons_to_fill_space = powerup_icons.size() >= min_icon_count


func delete_powerup_icons():
	for icon in powerup_icons:
		icon.queue_free()
	powerup_icons.clear()


func create_icons_for_all_powerups():
	for powerup in powerups:
		for i in powerup.probability:
			var icon = ICON_SCENE.instance()
			icon.associated_powerup = powerup
			icon_parent.add_child(icon)
			powerup_icons.push_back(icon)


func calc_icon_count_to_fill_icon_parent(icon_width: float) -> int:
	var icon_count_to_fill_space = icon_parent.rect_size.x / icon_width
	icon_count_to_fill_space = int(ceil(icon_count_to_fill_space))
	return icon_count_to_fill_space
