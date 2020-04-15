class_name Pinball
extends "res://Scripts/Roller.gd"
# Displays a marker at its position when inside the shop to remain visible,
# can be remote controlled, and sends out a signal when it gets destroyed or 
# becomes inaccessible so that the number of pinballs on the field can be
# monitored.

signal became_inaccessible

export var IS_ALWAYS_REMOTE_CONTROLLED = false
export var REMOTE_CONTROL_STRENGTH = 4.0
export var IS_REMOTE_CONTROL_FROM_PLAYER_POV = true

var is_accessible_to_player = true setget set_is_accessible_to_player
var is_remote_controlled = false setget set_is_remote_controlled
var is_remote_control_blocked = false

onready var remote_control_timer = get_node("RemoteControlTimer")
onready var remote_control_time_bar = get_node("RotationStabiliser/RemoteControlTimeBar3D/Viewport/Bar")
onready var arrow_sprite = get_node("RotationStabiliser/ArrowSprite")


func _ready():
	add_to_group("pinballs")
	remote_control_timer.connect("timeout", self, "on_RemoteControlTimer_timeout")
	arrow_sprite.set_visible(false)
	set_is_remote_controlled(IS_ALWAYS_REMOTE_CONTROLLED)


func _process(_delta):
	remote_control_time_bar.value = remote_control_timer.time_left


func _physics_process(delta):
	if is_remote_controlled and not is_remote_control_blocked:
		var dir = Vector3.ZERO
		if Input.is_action_pressed("ui_left"):
			dir += Vector3.UP.cross(linear_velocity)
		if Input.is_action_pressed("ui_right"):
			dir += linear_velocity.cross(Vector3.UP)
		if IS_REMOTE_CONTROL_FROM_PLAYER_POV and linear_velocity.z > 0:
			dir = -dir
		if dir.length() != 0:
			apply_central_impulse(dir * REMOTE_CONTROL_STRENGTH * delta)


func bid_farewell():
	set_is_accessible_to_player(false)


func on_visibility_changed(value):
	arrow_sprite.set_visible(!value)


func set_is_accessible_to_player(value):
	is_accessible_to_player = value
	if !value:
		emit_signal("became_inaccessible")


func set_is_remote_controlled(value, duration = 0):
	print("pinball remote: ", value)
	is_remote_controlled = value
	if not IS_ALWAYS_REMOTE_CONTROLLED and value and duration != 0:
		remote_control_timer.start(duration)
		remote_control_time_bar.max_value = duration
	remote_control_time_bar.set_visible(value)
	set_process(value)
	set_physics_process(value)


func on_RemoteControlTimer_timeout():
	set_is_remote_controlled(false)


func on_entered_laser_area():
	set_is_accessible_to_player(false)
	queue_free()
