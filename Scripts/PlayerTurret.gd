extends Spatial

signal was_loaded
signal has_shot

export var MAX_TURN_ANGLE = 45
export var TURN_SPEED = .5
export var MAX_SHOT_SPEED = 50
export var SHOT_CHARGE_SPEED = 1.0

var ball_to_shoot = null
var rotation_progress = 0.5
var shot_charge = 0

onready var dotted_line = get_node("Muzzle/DottedLine")
onready var dotted_line_start_transform = dotted_line.get_transform()
onready var start_transform = get_transform()
onready var min_transform  = get_transform().rotated(get_transform().basis.y.normalized(),
		deg2rad(-MAX_TURN_ANGLE))
onready var max_transform = get_transform().rotated(get_transform().basis.y.normalized(),
		deg2rad(MAX_TURN_ANGLE))


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	set_process(false)


func _input(event):
	if ball_to_shoot != null:
		if event.is_action_pressed("ui_down"):
			dotted_line.set_visible(true)
		elif event.is_action_released("ui_down"):
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
		if Input.is_action_pressed("ui_right"):
			if rotation_progress > 0:
				rotation_progress -= TURN_SPEED * delta
		if Input.is_action_pressed("ui_left"):
			if rotation_progress < 1:
				rotation_progress += TURN_SPEED * delta
		if Input.is_action_pressed("ui_down"):
			shot_charge = clamp(shot_charge + SHOT_CHARGE_SPEED * delta, 0, 1)
			var dotted_line_scale = Vector3(1, 1, lerp(1, 4, shot_charge))
			dotted_line.set_transform(dotted_line_start_transform.scaled(dotted_line_scale))
	
	if rotation_progress != old_rotation_progress:
		var min_basis = min_transform.basis.orthonormalized()
		var max_basis = max_transform.basis.orthonormalized()
		var new_rotation = Quat(min_basis.slerp(max_basis, rotation_progress))
		set_transform(Transform(new_rotation, get_transform().origin))	


func on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME:
		dotted_line.set_visible(false)
		ball_to_shoot = null
		set_process(false)
		var start_rotation = Quat(start_transform.basis.orthonormalized())
		set_transform(Transform(start_rotation, get_transform().origin))		


func insert_ball(ball):
	assert(ball.is_in_group("pinballs"))
	if ball_to_shoot != null:
		shoot(.5)
	Announcer.say("turret_active")
	ball.set_visible(false)
	ball.set_locked(true)
	ball.delayed_teleport($TeleporterExit.get_global_transform().origin)
	ball_to_shoot = ball
	emit_signal("was_loaded")
	set_process(true)
	delayed_announcer_instructions()


func shoot(plunger_progress):
	if ball_to_shoot == null:
		return
	dotted_line.set_visible(false)
	ball_to_shoot.set_locked(false)
	ball_to_shoot.set_visible(true)
	var plunger_force = .15 * pow(plunger_progress - 1.7, 3) + 1
	#print(plunger_force)
	ball_to_shoot.apply_central_impulse(-$TeleporterExit.get_global_transform().basis.z.normalized() * MAX_SHOT_SPEED * plunger_force)
	ball_to_shoot = null
	shot_charge = 0
	emit_signal("has_shot")


func delayed_announcer_instructions():
	yield(get_tree().create_timer(2.0), "timeout")
	if ball_to_shoot != null:
		Announcer.say("plunger_fire")
