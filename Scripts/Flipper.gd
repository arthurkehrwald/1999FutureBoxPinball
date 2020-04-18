extends KinematicBody

export var IS_RIGHT_FLIPPER = false
export var MAX_TURN_ANGLE = 60
export var TURN_SPEED = 500
export var forward_impulse_strength = 400
export var sideways_impulse_strength = 200
export var forward_missile_hits_to_player = true

var start_transform = Transform()
var max_transform = Transform()
var rotation_progress = 0.0
var input_code = ""

onready var impulse_area = get_node("ImpulseArea")


func _ready():
	add_to_group("flippers")
	start_transform = get_transform()	
	if IS_RIGHT_FLIPPER:
		input_code = "ui_right"
		max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(-MAX_TURN_ANGLE))
	else:
		input_code = "ui_left"
		max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(MAX_TURN_ANGLE))
	if Globals.player_ship == null:
		push_warning("[Flipper] can't find player! Missiles and explosions "
				+ "hitting this flipper will not damage the player.")

#func _input(event):
#	if event.is_action_pressed(input_code):
#		for body in impulse_area.get_overlapping_bodies():
#			var pointy_end_dir = get_global_transform().basis.orthonormalized().x
#			if IS_RIGHT_FLIPPER:
#				pointy_end_dir = -pointy_end_dir
#			var boost_factor = 1 - pointy_end_dir.angle_to(body.get_global_transform().origin - get_global_transform().origin) / PI
#			print(boost_factor)
#			body.apply_central_impulse(-get_global_transform().basis.orthonormalized().z * boost_factor * forward_impulse_strength)


func _physics_process(delta):	
	if Input.is_action_pressed(input_code):
		if rotation_progress < 1:
			rotation_progress += TURN_SPEED / MAX_TURN_ANGLE * delta
			for body in impulse_area.get_overlapping_bodies():
				body.apply_central_impulse(-get_global_transform().basis.z.normalized() - body.get_linear_velocity().normalized() * sideways_impulse_strength * delta)
				body.apply_central_impulse(-get_global_transform().basis.z.normalized() * forward_impulse_strength * delta)
	elif rotation_progress > 0:
		rotation_progress -= TURN_SPEED / MAX_TURN_ANGLE * delta
	
	var new_rotation = Quat(start_transform.basis.orthonormalized()).slerp(max_transform.basis.orthonormalized(), rotation_progress)
	set_transform(Transform(new_rotation, get_transform().origin))


func on_hit_by_projectile(projectile):
	if projectile.is_in_group("missiles") and Globals.player_ship != null:
		Globals.player_ship.on_hit_by_projectile(projectile)


func on_hit_by_explosion(explosion):
	if Globals.player_ship != null:
		Globals.player_ship.on_hit_by_explosion(explosion)
