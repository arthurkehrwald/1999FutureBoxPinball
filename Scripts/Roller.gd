class_name Roller
extends "res://Scripts/Projectile.gd"
# Can teleport and adjust gravity scale based on speed and grounded
# status. Abstract base class for 'Pinball.gd' and 'Bomb.gd'.

signal teleport_physics_cooldown_buffer_expired
signal physics_debug_info_update(speed, gravity)

const TELEPORT_PHYSICS_COOLDOWN_BUFFER = .02

export var AIRBORNE_GRAVITY_SCALE_MULTIPLIER = .4
export var SPEED_BASED_GRAVITY_SCALE = false

var _is_airborne = false
var _teleporting = false
var _teleport_physics_cooldown_time_remaining = 0

onready var _ray_cast = get_node("RotationStabiliser/RayCast")


func _enter_tree():
	GameState.connect("toggle_nightmode", self, "_on_GameState_toggle_nightmode")
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")


func _ready():
	set_process(false)


func _process(delta):
	_teleport_physics_cooldown_time_remaining -= delta
	if _teleport_physics_cooldown_time_remaining <= 0:
		set_process(false)
		emit_signal("teleport_physics_cooldown_buffer_expired")


func _physics_process(_delta):
	if _is_airborne == _ray_cast.is_colliding():
		_is_airborne = !_is_airborne
		if _is_airborne:
			if not SPEED_BASED_GRAVITY_SCALE:
				gravity_scale *= AIRBORNE_GRAVITY_SCALE_MULTIPLIER
			emit_signal("physics_debug_info_update", 1, 0)
		else:
			if not SPEED_BASED_GRAVITY_SCALE:
				gravity_scale /= AIRBORNE_GRAVITY_SCALE_MULTIPLIER
			emit_signal("physics_debug_info_update", 0, 1)
	if SPEED_BASED_GRAVITY_SCALE:
		_set_gravity_scale_based_on_speed()


func teleport(destination, maintain_velocity, impulse_on_exit):
	print("Ball or Bomb: _teleporting to - ", destination)
	
	var t = get_transform()
	t.origin = destination
	set_global_transform(t)

	set_sleeping(false)
	if !maintain_velocity:
		set_linear_velocity(Vector3(0,0,0))
		set_angular_velocity(Vector3(0,0,0))
	apply_central_impulse(impulse_on_exit)


func delayed_teleport(destination, impulse_on_exit = Vector3(0, 0, 0)):
	if _teleporting:
		return
	
	_teleporting = true
	set_physics_process(false)
	
	_teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	var t = get_global_transform()
	t.origin = destination
	set_global_transform(t)
	
	_teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	set_physics_process(true)
	_teleporting = false
	
	set_linear_velocity(Vector3(0,0,0))
	set_angular_velocity(Vector3(0,0,0))
	apply_central_impulse(impulse_on_exit)


func set_locked(is_locked):
	axis_lock_linear_x = is_locked
	axis_lock_linear_y = is_locked
	axis_lock_linear_z = is_locked
	axis_lock_angular_x = is_locked
	axis_lock_angular_y = is_locked
	axis_lock_angular_z = is_locked


func _set_gravity_scale_based_on_speed():
		#gravity_scale = clamp(-.2 * pow(.2 * get_linear_velocity().length(),
		#		2.7) + 15, 1, 15)
		gravity_scale = clamp(-.1 * pow(.2 * get_linear_velocity().length(),
				2.5) + 15, 5, 15)
		if _is_airborne:
			gravity_scale *= AIRBORNE_GRAVITY_SCALE_MULTIPLIER
		#gravity_scale = -get_linear_velocity().length() + 20
		emit_signal("physics_debug_info_update",
				get_linear_velocity().length(), 
				gravity_scale)


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		#queue_free()
		pass


func _on_GameState_toggle_nightmode(toggle):
	if toggle:
		$OmniLight.hide()
	else:
		$OmniLight.hide()


func _on_hit_area(area):
	pass


func _on_hit_body(body):
	pass
