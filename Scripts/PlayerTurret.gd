class_name PlayerTurret
extends KinematicBody

enum RotationDirection{
	NONE,
	LEFT,
	RIGHT
}

signal was_loaded
signal has_shot
signal is_active_changed(value)

export var MAX_TURN_ANGLE = 45
export var TURN_SPEED = .5
export(float) var shot_force := 50.0
export var SINK_INTO_GROUND_DIST = 1.0
export var path_to_dotted_line := NodePath()
export var path_to_muzzle := NodePath()
export var is_active := false setget set_is_active, get_is_active

var has_is_active_been_set := false
var ball_to_shoot: RigidBody = null
var rotation_progress = 0.5 setget set_rotation_progress
var rotation_direction = RotationDirection.NONE

onready var muzzle = get_node(path_to_muzzle) as Spatial
onready var dotted_line = get_node(path_to_dotted_line) as MeshInstance
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
	set_is_active(is_active)
	set_process(false)
	translation = Vector3(translation.x, min_y, translation.z)


func _input(event):
	if ball_to_shoot != null:
		if event.is_action_pressed("shoot_turret"):
			shoot()


func _process(delta):
	if ball_to_shoot == null:
		if rotation_progress == .5:
			rotation_direction = RotationDirection.NONE
			set_process(false)
		else:
			approach_centered_rotation(delta)
	else:
		match rotation_direction:
			RotationDirection.NONE:
				rotation_direction = RotationDirection.LEFT
			RotationDirection.LEFT:
				if rotation_progress < 1:
					set_rotation_progress(rotation_progress + TURN_SPEED * delta)
				else:
					rotation_direction = RotationDirection.RIGHT
			RotationDirection.RIGHT:
				if rotation_progress > 0:
					set_rotation_progress(rotation_progress - TURN_SPEED * delta)
				else:
					rotation_direction = RotationDirection.LEFT


func approach_centered_rotation(delta):
	if rotation_progress < .5:
		set_rotation_progress(min(.5, rotation_progress + TURN_SPEED * delta))
	else:
		set_rotation_progress(max(.5, rotation_progress - TURN_SPEED * delta))


func set_rotation_progress(value):
	if rotation_progress == value:
		return
	rotation_progress = value
	var min_basis = min_transform.basis.orthonormalized()
	var max_basis = max_transform.basis.orthonormalized()
	var new_rotation = Quat(min_basis.slerp(max_basis, rotation_progress))
	set_transform(Transform(new_rotation, get_transform().origin))


func on_hit_by_projectile(projectile):
	if projectile is Pinball:
		insert_ball(projectile)


func set_is_active(value : bool):
	if has_is_active_been_set and is_active == value:
		return
	var was_active := is_active
	is_active = value
	has_is_active_been_set = true
	if (was_active and ball_to_shoot):
		shoot()
	$Tween.remove(self, "translation:y")
	var from_y = min_y if value else max_y
	var to_y = max_y if value else min_y
	$Tween.interpolate_property(self, "translation:y",
		from_y, to_y, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	if !value:
		dotted_line.visible = false
	emit_signal("is_active_changed", is_active)


func get_is_active():
	return is_active


func insert_ball(ball):
	if ball == null or not ball.is_in_group("pinballs"):
		return
	if ball_to_shoot != null:
		shoot()
	Announcer.say("turret_active")
	dotted_line.set_visible(true)
	ball.set_locked(true)
	ball.teleport(muzzle.get_global_transform().origin)
	ball_to_shoot = ball
	emit_signal("was_loaded")
	set_process(true)
	delayed_announcer_instructions()


func shoot():
	if ball_to_shoot == null:
		return
	dotted_line.set_visible(false)
	ball_to_shoot.set_locked(false)
	ball_to_shoot.set_visible(true)
	ball_to_shoot.apply_central_impulse(-muzzle.get_global_transform().basis.z.normalized() * shot_force)
	ball_to_shoot = null
	emit_signal("has_shot")
	set_is_active(false)


func delayed_announcer_instructions():
	yield(get_tree().create_timer(1.0), "timeout")
	if ball_to_shoot != null:
		Announcer.say("plunger_fire")
