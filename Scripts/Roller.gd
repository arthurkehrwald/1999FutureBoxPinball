extends "res://Scripts/Projectile.gd"
# Can teleport and adjust gravity scale based on speed and grounded
# status. Deletes itself when it gets stuck. Abstract base class for
# 'Pinball.gd' and 'Bomb.gd'.

const E = 2.71828

export(float, 0, 20.0) var MAX_GRAV = 20.0
export(float, 0, 20.0) var MIN_GRAV = 5.0
export(float, 0, 1.0) var GRAV_CURVE_STEEPNESS = .5
export(float, 0, 1.0) var GRAV_CURVE_OFFSET = .5
export(float, 0, 50.0) var SPEED_LIM = 30.0
export var ENFORCE_SPEED_LIM = true
export var AIRBORNE_GRAV = 8.0
export var MAX_AUDIO_PITCH = 3
export var MIN_AUDIO_PITCH = .5
export var MIN_NOT_STUCK_DISTANCE_FROM_RECENT_LOCATION = .2
export var DETECT_STUCK_RECENT_LOCATION_SAMPLE_SIZE = 5

var is_locked_in_place = false
var current_wire_ramp = null
var recent_locations = []

onready var audio_player = get_node("AudioStreamPlayer3D")
onready var stuck_timer = get_node("DetectStuckTimer")


func _ready():
	add_to_group("rollers")
	stuck_timer.connect("timeout", self, "on_StuckTimer_timeout")


func _physics_process(_delta):
	update_gravity_scale()


func _process(_delta):
	var norm_z_pos = clamp((get_global_transform().origin.z + 8) / 16, 0, 1)
	audio_player.pitch_scale = lerp(MIN_AUDIO_PITCH, MAX_AUDIO_PITCH, norm_z_pos)


func on_StuckTimer_timeout():
	if is_stuck():
		queue_free()
		return
	if recent_locations.size() >= DETECT_STUCK_RECENT_LOCATION_SAMPLE_SIZE:
		recent_locations.pop_front()
	var location = global_transform.origin;
	recent_locations.push_back(location)

func teleport(destination):
	var t = Transform(get_global_transform().basis, destination)
	PhysicsServer.body_set_state(self.get_rid(), PhysicsServer.BODY_STATE_TRANSFORM, t)


func set_locked(is_locked):
	is_locked_in_place = is_locked
	axis_lock_linear_x = is_locked
	axis_lock_linear_y = is_locked
	axis_lock_linear_z = is_locked
	axis_lock_angular_x = is_locked
	axis_lock_angular_y = is_locked
	axis_lock_angular_z = is_locked


func update_gravity_scale():
	var speed = get_linear_velocity().length()
	if ENFORCE_SPEED_LIM and speed > SPEED_LIM:
		var capped_vel = get_linear_velocity().normalized() * SPEED_LIM
		PhysicsServer.body_set_state(self.get_rid(), PhysicsServer.BODY_STATE_LINEAR_VELOCITY, capped_vel)
		speed = capped_vel.length()
	var is_airborne = is_airborne()
	if is_airborne:
		gravity_scale = AIRBORNE_GRAV
	else:
		var a = 5 / ((1 - GRAV_CURVE_STEEPNESS - .5 * (1 - GRAV_CURVE_STEEPNESS)) * SPEED_LIM)
		var b = speed + (GRAV_CURVE_STEEPNESS * (1 - 2 * GRAV_CURVE_OFFSET) - 1) * SPEED_LIM * .5
		gravity_scale = (MIN_GRAV - MAX_GRAV) / (1 + pow(E, -a * b)) + MAX_GRAV
	$Label.text = "speed: %s\ngrav: %s\nairborne: %s" % [speed, gravity_scale, is_airborne]


func is_airborne():
	if hitreg_area.get_overlapping_bodies().empty():
		return true
	for body in hitreg_area.get_overlapping_bodies():
		if !body.is_in_group("projectiles"):
			return false
	return true


func is_stuck():
	if is_locked_in_place:
		return false
	for body in hitreg_area.get_overlapping_bodies():
		if body.is_in_group("flippers") or body.is_in_group("plunger"):
			return false
	if recent_locations.size() < DETECT_STUCK_RECENT_LOCATION_SAMPLE_SIZE:
		return false
	var location = global_transform.origin
	for recent_location in recent_locations:
		if location.distance_to(recent_location) > MIN_NOT_STUCK_DISTANCE_FROM_RECENT_LOCATION:
			return false
	return true
	
