class_name PlayerTurret
extends KinematicBody

signal was_loaded
signal has_shot
signal is_active_changed(value)

export var MAX_TURN_ANGLE = 45
export var TURN_SPEED = .5
export var MAX_SHOT_SPEED = 50
export var SHOT_CHARGE_SPEED = 1.0
export var TIME_SCALE_WHEN_AIMING = .1
export var SINK_INTO_GROUND_DIST = 1.0

var is_active = false setget set_is_active, get_is_active
var ball_to_shoot = null
var rotation_progress = 0.5
var shot_charge = 0

onready var muzzle = get_node("Muzzle")
onready var dotted_line = get_node("Muzzle/DottedLine")
onready var dotted_line_start_transform = dotted_line.get_transform()
onready var start_transform = get_transform()
onready var min_transform  = get_transform().rotated(get_transform().basis.y.normalized(),
		deg2rad(-MAX_TURN_ANGLE))
onready var max_transform = get_transform().rotated(get_transform().basis.y.normalized(),
		deg2rad(MAX_TURN_ANGLE))
onready var max_y = get_transform().origin.y
onready var min_y = max_y - SINK_INTO_GROUND_DIST


func _enter_tree():
	Globals.player_turret = self


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	set_process(false)
	translation = Vector3(translation.x, min_y, translation.z)


func _input(event):
	if ball_to_shoot != null:
		if event.is_action_released("plunger"):
			shoot(shot_charge)


func _process(delta):
	var old_rotation_progress = rotation_progress
	if ball_to_shoot == null:
		if rotation_progress == .5:
			set_process(false)
		elif rotation_progress < .5:
			rotation_progress = min(.5, rotation_progress + TURN_SPEED * delta)
		else:
			rotation_progress = max(.5, rotation_progress - TURN_SPEED * delta)
	else:
		if Input.is_action_pressed("flipper_right"):
			if rotation_progress > 0:
				rotation_progress -= TURN_SPEED / TIME_SCALE_WHEN_AIMING * delta
		if Input.is_action_pressed("flipper_left"):
			if rotation_progress < 1:
				rotation_progress += TURN_SPEED / TIME_SCALE_WHEN_AIMING * delta
		if Input.is_action_pressed("plunger"):
			shot_charge = clamp(shot_charge + SHOT_CHARGE_SPEED / TIME_SCALE_WHEN_AIMING * delta, 0, 1)
			var dotted_line_scale = Vector3(1, 1, lerp(1, 3, shot_charge))
			dotted_line.set_transform(dotted_line_start_transform.scaled(dotted_line_scale))
	
	if rotation_progress != old_rotation_progress:
		var min_basis = min_transform.basis.orthonormalized()
		var max_basis = max_transform.basis.orthonormalized()
		var new_rotation = Quat(min_basis.slerp(max_basis, rotation_progress))
		set_transform(Transform(new_rotation, get_transform().origin))	


func on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME_STATE:
		dotted_line.set_visible(false)
		ball_to_shoot = null
		set_process(false)
		var start_rotation = Quat(start_transform.basis.orthonormalized())
		set_transform(Transform(start_rotation, get_transform().origin))
		Engine.time_scale = 1


func on_hit_by_projectile(projectile):
	if projectile is Pinball:
		insert_ball(projectile)


func set_is_active(value : bool):
	if is_active == value:
		return
	is_active = value
	emit_signal("is_active_changed", is_active)
	if (is_active and ball_to_shoot):
		shoot(shot_charge)
	$Tween.remove(self, "translation:y")
	var from_y = min_y if is_active else max_y
	var to_y = max_y if is_active else min_y
	$Tween.interpolate_property(self, "translation:y",
		from_y, to_y, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func get_is_active():
	return is_active


func insert_ball(ball):
	if ball == null or not ball.is_in_group("pinballs"):
		return
	if ball_to_shoot != null:
		shoot(.5)
	Announcer.say("turret_active")
	dotted_line.set_visible(true)
	ball.set_locked(true)
	ball.teleport(muzzle.get_global_transform().origin)
	ball_to_shoot = ball
	emit_signal("was_loaded")
	set_process(true)
	delayed_announcer_instructions()
	Engine.time_scale = TIME_SCALE_WHEN_AIMING


func shoot(charge):
	if ball_to_shoot == null:
		return
	dotted_line.set_visible(false)
	ball_to_shoot.set_locked(false)
	ball_to_shoot.set_visible(true)
	var force = .15 * pow(charge - 1.7, 3) + 1
	ball_to_shoot.apply_central_impulse(-muzzle.get_global_transform().basis.z.normalized() * MAX_SHOT_SPEED * force)
	ball_to_shoot = null
	shot_charge = 0
	Engine.time_scale = 1
	emit_signal("has_shot")
	set_is_active(false)


func delayed_announcer_instructions():
	yield(get_tree().create_timer(1.0), "timeout")
	if ball_to_shoot != null:
		Announcer.say("plunger_fire")
