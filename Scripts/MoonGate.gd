class_name MoonGate
extends Spatial
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
export var impulse_strength = 3.0

var _is_flying = false
var _scale_state = ScaleState.SMALL
var _is_spinning = false
var _spin_speed = 0.0
var _spin_axis = Vector3(1, 0, 0)

onready var _hit_notifier = get_node("HitNotifier")
onready var _damageable = get_node("Damageable")
onready var _scale_anim_player = get_node("ScaleAnimPlayer")
onready var _fly_anim_player = get_node("FlyAnimPlayer")
onready var _mesh_instance = get_node("MeshInstance")


func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")


func _ready():
	_hit_notifier.connect("hit_by_pinball_directly", self, "_on_hit_by_projectile")
	_hit_notifier.connect("hit_by_bomb_directly", self, "_on_hit_by_projectile")
	_hit_notifier.connect("hit_by_missile_directly", self, "_on_hit_by_projectile")
	_damageable.connect("health_changed", self, "_on_Damageable_health_changed")
	_damageable.connect("death", self, "_on_Damageable_death")
	_scale_anim_player.connect("animation_finished", self, "_on_ScaleAnimPlayer_animation_finished")
	_fly_anim_player.connect("animation_finished", self, "_on_FlyAnimPlayer_animation_finished")
	set_process(false)


func _process(delta):
	_spin(delta)
	if _spin_speed <= 0:
		_is_spinning = false
		set_process(false)


func _start_spinning(var projectile_pos, var projectile_vel):
	var colliding_body_to_moon = get_global_transform().origin - projectile_pos
	_spin_axis = projectile_vel.cross(colliding_body_to_moon).normalized()
	_spin_speed = projectile_vel.length() * SPIN_SPEED_MULTIPLIER
	_is_spinning = true
	set_process(true)


func _spin(var delta):
	_spin_speed -= SPIN_SPEED_FALLOFF * delta
	if _spin_speed > 0:
		_mesh_instance.set_transform(
			_mesh_instance.get_transform().rotated(_spin_axis, _spin_speed * delta))
	else:
		if _scale_state == ScaleState.BIG or _scale_state == ScaleState.SCALING_UP:
			if not _is_flying:
				_scale_down()


func _start_flying():
	_is_flying = true
	_fly_anim_player.play("moon_fly", -1, 1 / FLIGHT_DURATION)


func _scale_up():
	_scale_state = ScaleState.SCALING_UP
	_scale_anim_player.play("moon_scale")
	set_visible(true)


func _scale_down():
	_scale_state = ScaleState.SCALING_DOWN
	_scale_anim_player.play_backwards("moon_scale")


func _on_hit_by_projectile(var projectile_pos, var projectile_vel):
	_start_spinning(projectile_pos, projectile_vel)


func _on_Damageable_health_changed(current_health, old_health, _max_health):
	print("health changed")
	if current_health < old_health:
		print("damage taken")
		if _scale_state == ScaleState.SMALL or _scale_state == ScaleState.SCALING_DOWN:
			print("scaling up")
			_scale_up()


func  _on_Damageable_death():
	if not _is_flying:
		_start_flying()


func _on_ScaleAnimPlayer_animation_finished(_anim_name):
	if _scale_state == ScaleState.SCALING_UP:
		if _is_flying or _is_spinning:
			_scale_state = ScaleState.BIG
		else:
			_scale_down()
	elif _scale_state == ScaleState.SCALING_DOWN:
		_scale_state = ScaleState.SMALL
		set_visible(false)


func _on_FlyAnimPlayer_animation_finished(_anim_name):
	if _is_flying:
		_is_flying = false
		_damageable.set_health(_damageable.MAX_HEALTH)
		_damageable.set_is_vulnerable(true)
	if not _is_spinning:
		_scale_down()


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if new_stage == GameState.PREGAME or is_debug_skip:
		_is_flying = false
		_is_spinning = false
		_scale_state = ScaleState.SMALL
		set_visible(false)
