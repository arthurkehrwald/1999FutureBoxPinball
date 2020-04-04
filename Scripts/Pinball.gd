class_name Pinball
extends "res://Scripts/Roller.gd"
# Displays a marker at its position when inside the shop to remain visible,
# can be remote controlled, and sends out a signal when it gets destroyed or 
# becomes inaccessible so that the number of pinballs on the field can be
# monitored.

signal became_inaccessible

export var remote_control_strength = 1.0

var is_accessible_to_player = true setget set_is_accessible_to_player
var is_remote_controlled = false setget set_is_remote_controlled
var is_remote_control_blocked = false

onready var remote_control_timer = get_node_or_null("/root/Main/RemoteBallControlTimer")
onready var remote_control_time_bar = get_node("RotationStabiliser/RemoteControlTimeBar")
onready var wallhack_marker = get_node("RotationStabiliser/WallhackMarker")


func _ready():
	if remote_control_timer == null:
		print("Ball: could not find remote control timer")
		set_is_remote_controlled(false)
	else:
		remote_control_timer.connect("start", self, "_on_RemoteControlTimer_start")
		remote_control_timer.connect("timeout", self, "_on_RemoteControlTimer_timeout")
		remote_control_timer.connect("time_left_changed", remote_control_time_bar, "update_value", [1, 0])
		set_is_remote_controlled(!remote_control_timer.is_stopped())
	wallhack_marker = get_node("RotationCancel/Arrowwallhack_marker")
	wallhack_marker.set_visible(false)


func _physics_process(_delta):
	if is_remote_controlled and not is_remote_control_blocked:
		if Input.is_action_pressed("flipper_left") and not Input.is_action_pressed("flipper_right"):
			apply_central_impulse(Vector3(-1, 0, 0) * remote_control_strength * clamp(abs(linear_velocity.z) * .05, 0, 1))
		if Input.is_action_pressed("flipper_right") and not Input.is_action_pressed("flipper_left"):
			apply_central_impulse(Vector3(1, 0, 0) * remote_control_strength * clamp(abs(linear_velocity.z) * .05, 0, 1))


func delete():
	GameState.balls_on_field -= 1
	set_is_accessible_to_player(false)
	queue_free()


func on_visibility_changed(value):
	wallhack_marker.set_visible(!value)


func set_is_accessible_to_player(value):
	is_accessible_to_player = value
	if !value:
		emit_signal("became_inaccessible")


func set_is_remote_controlled(value):
	is_remote_controlled = value
	remote_control_time_bar.set_visible(value)


func _on_destroyed():
	GameState.add_player_money(-GameState.BALL_DESTROYED_COST)
	if GameState.balls_on_field > 1:
		delete()
	else:
		delayed_teleport(GameState.ball_spawn_pos)


func _on_RemoteControlTimer_start():
	set_is_remote_controlled(true)


func _on_RemoteControlTimer_timeout():
	set_is_remote_controlled(false)


func _on_HitregArea_area_entered(area):
	if area.has_method("on_hit_by_pinball_directly"):
		area.on_hit_by_pinball_directly(get_global_transform().origin,
				get_linear_velocity())


func _on_HitregArea_body_entered(body):
	if body.has_method("on_hit_by_pinball_directly"):
		body.on_hit_by_pinball_directly(get_global_transform().origin,
				get_linear_velocity())
