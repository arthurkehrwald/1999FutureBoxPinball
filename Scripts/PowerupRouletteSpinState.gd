class_name PowerupRouletteSpinState
extends "res://Scripts/UiState.gd"

const ICON_SCENE = preload("res://Scenes/PowerupIcon.tscn")

signal selected_powerup(powerup)

export var seconds_to_present_powerups_without_duration := 5.0
export var start_speed := 10.0
export var speed_decay := 1.0
export var path_to_icon_parent := NodePath()
export var path_to_tween := NodePath()
export var path_to_name_label := NodePath()
export var path_to_time_bar := NodePath()

var speed := 0.0
var spin_progress := 0.0 setget set_spin_progress
var powerup_icons := []
var unscaled_icon_width: float
var powerups := []
var selected_powerup: Powerup

onready var icon_parent := get_node(path_to_icon_parent) as Control
onready var default_speed_decay := speed_decay
onready var tween := get_node(path_to_tween) as Tween
onready var name_label := get_node(path_to_name_label) as Label
onready var time_bar := get_node(path_to_time_bar) as TextureProgress

func _on_enter(params := {}):
	default_speed_decay = speed_decay
	speed_decay = params["speed_decay"] if params.has("speed_decay") else speed_decay
	speed = params["start_speed"] if params.has("start_speed") else start_speed
	powerups = params["powerups"]
	time_bar.visible = false
	name_label.visible = false
	prepare_powerup_icons()
	._on_enter(params)


func _on_exit(passthrough_params := {}):
	speed_decay = default_speed_decay
	powerups.clear()
	selected_powerup = null
	var params := {"selected_powerup": selected_powerup}
	params = Utils.merge_dict(params, passthrough_params)
	._on_exit(params)


func _process(delta):
	if speed > 0:
		set_spin_progress(spin_progress + speed * delta)
		speed -= speed_decay * delta
	elif !selected_powerup:
		var selected_icon = get_center_icon()
		selected_powerup = selected_icon.associated_powerup
		emit_signal("selected_powerup", selected_powerup)
		trigger_selection_animation(selected_icon)
		selected_icon.connect("selection_animation_finished", self, "_on_PowerupIcon_selection_animation_finished", [], CONNECT_ONESHOT)
	elif selected_powerup.duration > 0.0:
		time_bar.value = selected_powerup.get_time_left()

func prepare_powerup_icons():
	delete_powerup_icons()
	create_icons_for_all_powerups()
	if powerup_icons.empty():
		return
	unscaled_icon_width = powerup_icons[0].rect_size.x
	var min_icon_count = calc_icon_count_to_fill_icon_parent() + 1
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


func calc_icon_count_to_fill_icon_parent() -> int:
	var icon_count_to_fill_space = icon_parent.rect_size.x / unscaled_icon_width
	icon_count_to_fill_space = int(ceil(icon_count_to_fill_space))
	return icon_count_to_fill_space


func set_spin_progress(value: float):
	spin_progress = fmod(value, 1.0)
	var visible_icons = calc_icon_count_to_fill_icon_parent() + 1
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


func _on_PowerupIcon_selection_animation_finished():
	if selected_powerup != null:
		present_powerup(selected_powerup)

func present_powerup(powerup: Powerup):
	name_label.visible = true
	name_label.text = selected_powerup.powerup_name
	if powerup.duration > 0.0:
		time_bar.visible = true
		time_bar.max_value = selected_powerup.duration
		powerup.connect("is_active_changed", self, "_on_SelectedPowerup_is_active_changed", [], CONNECT_ONESHOT)
	else:
		var timer = get_tree().create_timer(seconds_to_present_powerups_without_duration)
		timer.connect("timeout", self, "_on_PresentPowerupTimer_timeout")


func _on_PresentPowerupTimer_timeout():
	exit()

func _on_SelectedPowerup_is_active_changed(value):
	if !value:
		exit()
