class_name Roller
extends "res://Scripts/Projectile.gd"
# Can teleport and adjust gravity scale based on speed and grounded
# status. Abstract base class for 'Pinball.gd' and 'Bomb.gd'.

signal teleport_physics_cooldown_buffer_expired
signal physics_debug_info_update(speed, gravity)

const TELEPORT_PHYSICS_COOLDOWN_BUFFER = .02

export var AIRBORNE_GRAVITY_SCALE_MULTIPLIER = .4
export var SPEED_BASED_GRAVITY_SCALE = false

var is_airborne = false
var teleporting = false
var teleport_physics_cooldown_time_remaining = 0


func _ready():
	add_to_group("rollers")
	set_process(false)


func _process(delta):
	teleport_physics_cooldown_time_remaining -= delta
	if teleport_physics_cooldown_time_remaining <= 0:
		set_process(false)
		emit_signal("teleport_physics_cooldown_buffer_expired")


func _physics_process(_delta):
	var was_airborne = is_airborne
	if was_airborne and not get_colliding_bodies().empty():
		for body in get_colliding_bodies():
			if not body.is_in_group("projectiles"):
				is_airborne = false
	elif not was_airborne and get_colliding_bodies().empty():
		is_airborne = true
	if is_airborne != was_airborne:
		if is_airborne:
			if not SPEED_BASED_GRAVITY_SCALE:
				gravity_scale *= AIRBORNE_GRAVITY_SCALE_MULTIPLIER
		else:
			if not SPEED_BASED_GRAVITY_SCALE:
				gravity_scale /= AIRBORNE_GRAVITY_SCALE_MULTIPLIER
	if SPEED_BASED_GRAVITY_SCALE:
		set_gravity_scale_based_on_speed()


func bid_farewell():
	pass


func teleport(destination):
	set_global_transform(Transform(get_global_transform().basis, destination))
	
	if not is_airborne:
		is_airborne = true
		if not SPEED_BASED_GRAVITY_SCALE:
			gravity_scale *= AIRBORNE_GRAVITY_SCALE_MULTIPLIER


func delayed_teleport(destination, impulse_on_exit = Vector3(0, 0, 0)):
	if teleporting:
		return
	
	teleporting = true
	set_physics_process(false)
	
	teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	var t = get_global_transform()
	t.origin = destination
	set_global_transform(t)
	
	teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	set_physics_process(true)
	teleporting = false
	
	set_linear_velocity(Vector3(0,0,0))
	set_angular_velocity(Vector3(0,0,0))
	apply_central_impulse(impulse_on_exit)
	
	if not is_airborne:
		is_airborne = true
		if not SPEED_BASED_GRAVITY_SCALE:
			gravity_scale *= AIRBORNE_GRAVITY_SCALE_MULTIPLIER


func set_locked(is_locked):
	axis_lock_linear_x = is_locked
	axis_lock_linear_y = is_locked
	axis_lock_linear_z = is_locked
	axis_lock_angular_x = is_locked
	axis_lock_angular_y = is_locked
	axis_lock_angular_z = is_locked


func set_gravity_scale_based_on_speed():
		#gravity_scale = clamp(-.2 * pow(.2 * get_linear_velocity().length(),
		#		2.7) + 15, 1, 15)
		gravity_scale = clamp(-.1 * pow(.2 * get_linear_velocity().length(),
				2.5) + 15, 5, 15)
		if is_airborne:
			gravity_scale *= AIRBORNE_GRAVITY_SCALE_MULTIPLIER
		#gravity_scale = -get_linear_velocity().length() + 20
		emit_signal("physics_debug_info_update",
				get_linear_velocity().length(), 
				gravity_scale)


func on_entered_laser_area():
	.on_entered_laser_area()
