extends "res://Scripts/Projectile.gd"
# Can teleport and adjust gravity scale based on speed and grounded
# status. Abstract base class for 'Pinball.gd' and 'Bomb.gd'.

const E = 2.71828

export(float, 0, 20.0) var MAX_GRAV = 20.0
export(float, 0, 20.0) var MIN_GRAV = 5.0
export(float, 0, 1.0) var GRAV_CURVE_STEEPNESS = .5
export(float, 0, 1.0) var GRAV_CURVE_OFFSET = .5
export(float, 0, 50.0) var SPEED_LIM = 30.0
export var ENFORCE_SPEED_LIM = true
export var AIRBORNE_GRAV_FACTOR = 1.0


func _ready():
	add_to_group("rollers")


func _physics_process(_delta):
	var speed = get_linear_velocity().length()
	if ENFORCE_SPEED_LIM and speed > SPEED_LIM:
		var capped_vel = get_linear_velocity().normalized() * Globals.ROLLER_TOPSPEED
		set_linear_velocity(capped_vel)
		speed = capped_vel.length()
	var a = 5 / ((1 - GRAV_CURVE_STEEPNESS - .5 * (1 - GRAV_CURVE_STEEPNESS)) * SPEED_LIM)
	var b = speed + (GRAV_CURVE_STEEPNESS * (1 - 2 * GRAV_CURVE_OFFSET) - 1) * SPEED_LIM * .5
	gravity_scale = (MIN_GRAV - MAX_GRAV) / (1 + pow(E, -a * b)) + MAX_GRAV
	if area.get_overlapping_bodies().empty():
		gravity_scale *= AIRBORNE_GRAV_FACTOR
	$Label.text = "speed: %s\ngrav: %s\nairborne: %s" % [speed, gravity_scale, area.get_overlapping_bodies().empty()]


func teleport(destination):
	var t = Transform(get_global_transform().basis, destination)
	PhysicsServer.body_set_state(self.get_rid(), PhysicsServer.BODY_STATE_TRANSFORM, t)


func set_locked(is_locked):
	axis_lock_linear_x = is_locked
	axis_lock_linear_y = is_locked
	axis_lock_linear_z = is_locked
	axis_lock_angular_x = is_locked
	axis_lock_angular_y = is_locked
	axis_lock_angular_z = is_locked
