class_name MoonGate
extends "res://Scripts/Damageable.gd"
# The mobile, partially transparent part of the moon:
# - Becomes visible and scales up when its Damageable node takes damage.
# - Spins when its HitNotifier node gets hit by a pojectile.
# - Flies (predefined animation) when its Damageable node dies.
# - Scales down and becomes invisible as soon as it is neither spinning nor flying.

enum In {
	FLY_ANIM_DONE,
	DEATH,
	DAMAGED,
	SCALE_ANIM_DONE,
	STOPPED_SPINNING,
	HIT_BY_PROJECTILE
}
enum ScaleState {
	SMALL,
	BIG,
	SCALING_UP,
	SCALING_DOWN
}

export var FLIGHT_DURATION = 5.0
export var SPIN_SPEED_MULTIPLIER = 1.0
export var SPIN_SPEED_FALLOFF = 1.4
export var IMPULSE_STRENGTH = 3.0

var is_flying = false
var scale_state = ScaleState.SMALL
var is_spinning = false
var spin_speed = 0.0
var spin_axis = Vector3(1, 0, 0)

onready var scale_anim_player = get_node("ScaleAnimPlayer")
onready var fly_anim_player = get_node("FlyAnimPlayer")
onready var mesh = get_node("MeshInstance")


func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("health_changed", self, "on_health_changed")
	connect("death", self, "on_death")
	scale_anim_player.connect("animation_finished", self, "on_ScaleAnimPlayer_animation_finished")
	fly_anim_player.connect("animation_finished", self, "on_FlyAnimPlayer_animation_finished")
	set_process(false)


func _process(delta):
	if spin_speed > 0:
		spin(delta)
	else:
		is_spinning = false
		set_process(false)
		if scale_state == ScaleState.BIG or scale_state == ScaleState.SCALING_UP:
			if not is_flying:
				scale_down()


func on_body_entered(var body):
	if not body.is_in_group("projectiles"):
		return
	.on_hit_by_projectile(body)
	var body_pos = body.get_global_transform().origin
	var body_vel = body.get_linear_velocity()
	start_spinning(body_pos, body_vel)
	if is_flying and body_pos.z > get_global_transform().origin.z:
		body.apply_central_impulse(Vector3.FORWARD * IMPULSE_STRENGTH)
		if body.is_in_group("pinballs"):
			body.on_hit_moon()


func start_spinning(var projectile_pos, var projectile_vel):
	var colliding_body_to_moon = get_global_transform().origin - projectile_pos
	spin_axis = projectile_vel.cross(colliding_body_to_moon).normalized()
	spin_speed = projectile_vel.length() * SPIN_SPEED_MULTIPLIER
	is_spinning = true
	set_process(true)


func spin(var delta):
	mesh.set_transform(
			mesh.get_transform().rotated(spin_axis, spin_speed * delta))
	spin_speed -= SPIN_SPEED_FALLOFF * delta


func start_flying():
	is_flying = true
	fly_anim_player.play("moon_fly", -1, 1 / FLIGHT_DURATION)
	PoolManager.request(PoolManager.MOON_TRIGGERED, get_global_transform().origin)


func _scale_up():
	scale_state = ScaleState.SCALING_UP
	scale_anim_player.play("moon_scale")
	set_visible(true)


func scale_down():
	scale_state = ScaleState.SCALING_DOWN
	scale_anim_player.play_backwards("moon_scale")


func on_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		if scale_state == ScaleState.SMALL or scale_state == ScaleState.SCALING_DOWN:
			_scale_up()


func  on_death():
	if not is_flying:
		start_flying()


func on_ScaleAnimPlayer_animation_finished(_anim_name):
	if scale_state == ScaleState.SCALING_UP:
		if is_flying or is_spinning:
			scale_state = ScaleState.BIG
		else:
			scale_down()
	elif scale_state == ScaleState.SCALING_DOWN:
		scale_state = ScaleState.SMALL
		set_visible(false)


func on_FlyAnimPlayer_animation_finished(_anim_name):
	if is_flying:
		is_flying = false
		set_health(MAX_HEALTH)
		set_is_vulnerable(true)
	if not is_spinning:
		scale_down()


func on_GameState_changed(new_state, is_debug_skip):
	.on_GameState_changed(new_state, is_debug_skip)
	if new_state == GameState.PREGAME or is_debug_skip:
		is_flying = false
		is_spinning = false
		scale_state = ScaleState.SMALL
		scale_anim_player.stop()
		fly_anim_player.stop()
		set_visible(false)
