extends "res://Scripts/Flipper.gd"

onready var active_timer = get_node("ActiveTimer")
onready var active_time_bar = get_node("ActiveTimeBar3D/Viewport/Bar")
onready var collision_shape_1 = get_node("CollisionShape")
onready var collision_shape_2 = get_node("CollisionShape2")
onready var collision_shape_3 = get_node("CollisionShape3")
onready var collision_shape_4 = get_node("CollisionShape4")
onready var no_remote_control_area = get_node("NoRemoteControlArea")


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	if Globals.shop_menu != null:
		Globals.shop_menu.connect("bought_flipper", self, "on_ShopMenu_bought_flipper")
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("selected_flipper", self, "on_PowerupRoulette_selected_flipper")
	active_timer.connect("timeout", self, "on_ActiveTimer_timeout")
	set_process(false)


func _process(_delta):
	active_time_bar.value = active_timer.time_left


func on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME_STATE:
		set_is_active(false)


func set_is_active(value, duration = 0):
	if value and duration == 0:
		return
	set_process(value)
	set_physics_process(value)
	set_visible(value)
	if value:
		active_time_bar.max_value = duration
		active_timer.start(duration)
	else:
		active_timer.stop()
	collision_shape_1.set_deferred("disabled", !value)
	collision_shape_2.set_deferred("disabled", !value)
	collision_shape_3.set_deferred("disabled", !value)
	collision_shape_4.set_deferred("disabled", !value)
	no_remote_control_area.set_deferred("monitoring", value)
	impulse_area.set_deferred("monitoring", value)


func on_ShopMenu_bought_flipper(duration):
	set_is_active(true, duration)


func on_PowerupRoulette_selected_flipper(duration):
	set_is_active(true, duration)


func on_ActiveTimer_timeout():
	set_is_active(false)
