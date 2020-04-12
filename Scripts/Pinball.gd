class_name Pinball
extends "res://Scripts/Roller.gd"
# Displays a marker at its position when inside the shop to remain visible,
# can be remote controlled, and sends out a signal when it gets destroyed or 
# becomes inaccessible so that the number of pinballs on the field can be
# monitored.

signal became_inaccessible

export var IS_ALWAYS_REMOTE_CONTROLLED = false
export var REMOTE_CONTROL_STRENGTH = 1.0
export var REMOTE_CONTROL_DURATION = 10.0

var is_accessible_to_player = true setget set_is_accessible_to_player
var is_remote_controlled = IS_ALWAYS_REMOTE_CONTROLLED setget set_is_remote_controlled
var is_remote_control_blocked = false

onready var remote_control_timer = get_node("RemoteControlTimer")
onready var remote_control_time_bar = get_node("RotationStabiliser/RemoteControlTimeBar3D/Viewport/Bar")
onready var arrow_sprite = get_node("RotationStabiliser/ArrowSprite")


func _ready():
	add_to_group("pinballs")
	arrow_sprite.set_visible(false)
	remote_control_time_bar.max_value = REMOTE_CONTROL_DURATION
	set_is_remote_controlled(IS_ALWAYS_REMOTE_CONTROLLED)


func _process(_delta):
	remote_control_time_bar.value = remote_control_timer.time_left


func _physics_process(_delta):
	if is_remote_controlled and not is_remote_control_blocked:
		if Input.is_action_pressed("flipper_left") and not Input.is_action_pressed("flipper_right"):
			var velocity_factor = clamp(abs(linear_velocity.z) * .05, 0, 1)
			apply_central_impulse(Vector3(-1, 0, 0) * REMOTE_CONTROL_STRENGTH * velocity_factor)
		if Input.is_action_pressed("flipper_right") and not Input.is_action_pressed("flipper_left"):
			var velocity_factor = clamp(abs(linear_velocity.z) * .05, 0, 1)
			apply_central_impulse(Vector3(1, 0, 0) * REMOTE_CONTROL_STRENGTH * velocity_factor)


func bid_farewell():
	set_is_accessible_to_player(false)


func on_visibility_changed(value):
	arrow_sprite.set_visible(!value)


func set_is_accessible_to_player(value):
	is_accessible_to_player = value
	if !value:
		emit_signal("became_inaccessible")


func set_is_remote_controlled(value):
	is_remote_controlled = value
	if not IS_ALWAYS_REMOTE_CONTROLLED:
		remote_control_timer.start(REMOTE_CONTROL_DURATION)
		remote_control_time_bar.set_visible(value)
		set_process(value)


func _on_RemoteControlTimer_timeout():
	set_is_remote_controlled(false)


func on_entered_laser_area():
	set_is_accessible_to_player(false)
	queue_free()
