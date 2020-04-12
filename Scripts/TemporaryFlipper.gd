extends "res://Scripts/Flipper.gd"

export var DURATION = 15.0

onready var active_timer = get_node("ActiveTimer")
onready var active_time_bar = get_node("ActiveTimeBar3D/Viewport/Bar")
onready var collision_shape_1 = get_node("CollisionShape")
onready var collision_shape_2 = get_node("CollisionShape2")
onready var collision_shape_3 = get_node("CollisionShape3")
onready var collision_shape_4 = get_node("CollisionShape4")


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	active_timer.connect("timeout", self, "on_ActiveTimer_timeout")
	active_time_bar.max_value = DURATION
	set_process(false)


func _process(_delta):
	active_time_bar.value = active_timer.time_left


func on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		set_is_active(false)


func set_is_active(is_active):
	set_process(is_active)
	set_visible(is_active)
	if is_active:
		active_timer.start()
	else:
		active_timer.stop()
	collision_shape_1.set_deferred("disabled", !is_active)
	collision_shape_2.set_deferred("disabled", !is_active)
	collision_shape_3.set_deferred("disabled", !is_active)
	collision_shape_4.set_deferred("disabled", !is_active)


func _on_ShopMenu_bought_flipper():
	if active_timer.is_stopped():
		set_is_active(true)
	else:
		active_timer.stop()
		active_timer.start()


func on_ActiveTimer_timeout():
	set_is_active(false)
