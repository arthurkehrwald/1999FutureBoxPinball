extends KinematicBody

export var IS_RIGHT_FLIPPER = false
export var MAX_TURN_ANGLE = 60
export var TURN_SPEED = 500
export var IMPULSE_STRENGTH = 50
export var MAX_IMPULSE_ANGLE = 45


var start_transform = Transform()
var max_transform = Transform()
var rotation_progress = 0.0
var input_code = ""

onready var impulse_area = get_node("ImpulseArea")
onready var friction_area = get_node("FrictionArea")
onready var audio_player = get_node("AudioStreamPlayer")
onready var start_basis = get_global_transform().basis


func _ready():
	add_to_group("flippers")
	start_transform = get_transform()
	impulse_area.connect("body_entered", self, "on_ImpulseArea_body_entered")
	if IS_RIGHT_FLIPPER:
		input_code = "flipper_right"
		max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(-MAX_TURN_ANGLE))
	else:
		input_code = "flipper_left"
		max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(MAX_TURN_ANGLE))
	if Globals.player_ship == null:
		push_warning("[Flipper] can't find player! Missiles and explosions "
				+ "hitting this flipper will not damage the player.")
	set_physics_process(false)


func _input(event):
	if event.is_action_pressed(input_code):
		set_physics_process(true)
		audio_player.play()


func _physics_process(delta):
	if Input.is_action_pressed(input_code):
		if rotation_progress <= 1:
			set_rot_progress(rotation_progress + TURN_SPEED * delta)
	elif rotation_progress > 0:
		set_rot_progress(rotation_progress - TURN_SPEED * delta)


func set_rot_progress(value):
	if value == rotation_progress:
		return
	var prev = rotation_progress
	rotation_progress = clamp(value, 0.0, 1.0)
	var new_rotation = Quat(start_transform.basis.orthonormalized()).slerp(max_transform.basis.orthonormalized(), rotation_progress)
	set_transform(Transform(new_rotation, get_transform().origin))
	if rotation_progress == 1 or rotation_progress == 0:
			impulse_area.set_deferred("monitoring", false)
	elif prev == 0 or prev == 1 and prev < rotation_progress:
		impulse_area.set_deferred("monitoring", true)
	if rotation_progress == 1:
		friction_area.set_deferred("monitoring", true)
	elif prev == 1:
		friction_area.set_deferred("monitoring", false)
	if rotation_progress == 0:
		set_physics_process(false)
	
	


func on_ImpulseArea_body_entered(body):
	if !body.is_in_group("rollers"):
		return
	var dist = (body.get_global_transform().origin - get_global_transform().origin).length()
	var angle = (1.2 - dist) * deg2rad(MAX_IMPULSE_ANGLE)
	if IS_RIGHT_FLIPPER:
		angle = -angle
	var dir = -start_basis.z.rotated(start_basis.y.normalized(), angle)
	body.apply_central_impulse(dir * dist * IMPULSE_STRENGTH)


func on_hit_by_projectile(projectile):
	if projectile.is_in_group("missiles") and Globals.player_ship != null:
		Globals.player_ship.on_hit_by_projectile(projectile)


func on_hit_by_explosion(explosion):
	if Globals.player_ship != null:
		Globals.player_ship.on_hit_by_explosion(explosion)
