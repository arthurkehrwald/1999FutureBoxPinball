extends Control

signal is_active_changed(value)
signal selected_repair(heal_percent)
signal selected_turret(pinball_in_shop)
signal selected_flipper(duration)
signal selected_boost
signal selected_remote_on_deleted_ball
signal selected_turret_on_deleted_ball

const ICONS_VISIBLE_AT_A_TIME = 4

export var PLAYER_REPAIR_HEAL_PERCENT = 50.0
export var EXTRA_FLIPPER_DURATION = 30.0
export var SPIN_SPEED = 30.0
export var SPEED_DECAY = 100.0

var speed = 700
var pinball_in_shop = null
var is_active = false
var rng = RandomNumberGenerator.new()

onready var icons = get_node("Icons")
onready var move_range = icons.get_child(0).rect_size.x * ICONS_VISIBLE_AT_A_TIME
onready var icon_width = icons.get_child(0).rect_size.x * .5
onready var max_progress = 1.0 / ICONS_VISIBLE_AT_A_TIME * icons.get_child_count()
onready var tween = get_node("Tween")
onready var glitch_overlay = get_node("../GlitchOverlay")


func _enter_tree():
	Globals.powerup_roulette = self


func _ready():
	set_physics_process(false)
	set_visible(false)


func _physics_process(delta):
	for icon in icons.get_children():
		var progress = (icon.rect_position.x + icon_width) / move_range
		if progress >= max_progress:
			icon.rect_position.x = -icon_width
		icon.rect_position.x += speed * delta
		var scale = -2 * pow(progress - .5, 2) + 1
		icon.rect_scale = Vector2.ONE * scale
		if progress < .2:
			icon.modulate = Color(1, 1, 1, progress * 5)
		elif progress > .8:
			icon.modulate = Color(1, 1 , 1, (1 - progress) * 5)
	speed -= SPEED_DECAY * delta
	if speed <= 0:
		var selected_index = 0
		var selected_icon = null
		var min_offset_from_center = move_range
		var i = 0
		for icon in icons.get_children():
			var offset = icon.rect_position.x + icon_width
			var offset_from_center = abs((.5 * move_range) - offset)
			if offset_from_center < min_offset_from_center:
				min_offset_from_center = offset_from_center
				selected_index = i
				selected_icon = icon
			i += 1
		for icon in icons.get_children():
			if icon == selected_icon:
				tween.interpolate_property(icon, "rect_position",
						icon.rect_position, Vector2(move_range * .5 - icon_width, 0),
						 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				icon.get_node("AnimationPlayer").play("powerup_icon_scale_up")
			else:
				tween.interpolate_property(icon, "modulate",
						icon.modulate, Color(1, 1, 1, 0),
						 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				tween.interpolate_property(icon, "rect_scale",
						icon.rect_scale, Vector2.ZERO,
						 .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		match selected_index:
			0:
				emit_signal("selected_repair", PLAYER_REPAIR_HEAL_PERCENT)
				print("rolled repair")
			1: 
				if pinball_in_shop != null and pinball_in_shop.get_ref():
					emit_signal("selected_turret", pinball_in_shop.get_ref())
				else:
					emit_signal("selected_turret_on_deleted_ball")
				print("rolled turret")
			2:
				if pinball_in_shop != null and pinball_in_shop.get_ref():
					pinball_in_shop.get_ref().set_is_remote_controlled(true)
				else:
					emit_signal("selected_remote_on_deleted_ball")
				print("rolled remote")
			3: 
				emit_signal("selected_flipper", EXTRA_FLIPPER_DURATION)
				print("rolled flipper")
			4: 
				emit_signal("selected_boost")
				print("rolled boost")
		set_is_active(false)


func set_is_active(value, _pinball_in_shop = null):
	if is_active == value:
		return
	if _pinball_in_shop != null:
		pinball_in_shop = weakref(_pinball_in_shop)
	else:
		pinball_in_shop = null
	set_physics_process(value)
	if value:
		if pinball_in_shop != null and pinball_in_shop.get_ref():
			speed = pinball_in_shop.get_ref().get_linear_velocity().length() * SPIN_SPEED
			speed = 700 + rand_range(0, 100)
			print(speed)
		var i = 0
		for icon in icons.get_children():
			icon.rect_scale = Vector2.ONE
			icon.modulate = Color(1, 1, 1, 1)
			icon.rect_position.x = icon.rect_size.x * i
			i += 1
	else:
		yield(get_tree().create_timer(3), "timeout")
	if glitch_overlay != null:
		glitch_overlay.super_glitch()
	is_active = value
	set_visible(value)
	emit_signal("is_active_changed", value)
