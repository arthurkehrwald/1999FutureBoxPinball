extends "res://Scripts/Projectile.gd"

enum Thruster {NONE, LEFT, RIGHT}

const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")
const GUIDANCE_UPDATE_RATE = 0.2
const INACCURACY_TOLERANCE = 0.1

export var SPEED = 1.0
export var TURN_FORCE = .3
export var MAX_TURN_SPEED = 5.0
export var VERTICAL_GUIDANCE = false

var start_basis = Basis.IDENTITY
var target_pos = Vector3.ZERO

onready var animation_player = get_node("AnimationPlayer")
onready var target_pointer = get_node("TargetPointer")
onready var steering_flames = get_node("SteeringFlames")
onready var left_exhaust_flame = get_node("SteeringFlames/LeftExhaustFlame")
onready var right_exhaust_flame = get_node("SteeringFlames/RightExhaustFlame")
onready var bottom_exhaust_flame = get_node("SteeringFlames/BottomExhaustFlame")
onready var top_exhaust_flame = get_node("SteeringFlames/TopExhaustFlame")
onready var guidance_update_timer = get_node("GuidanceUpdateTimer")


func _ready():
	add_to_group("missiles")
	guidance_update_timer.connect("timeout", self, "on_GuidanceUpdateTimer_timeout")
	animation_player.connect("animation_finished", self, "on_AnimationPlayer_animation_finished")
	animation_player.play("missile_launch", -1, SPEED)
	set_visible(false)


func _process(_delta):
	var steering_flames_pos = steering_flames.get_global_transform().origin
	var forward_transform_with_no_roll = Transform(Basis.IDENTITY, steering_flames_pos)
	steering_flames.set_global_transform(forward_transform_with_no_roll)
	steering_flames.look_at(steering_flames_pos - get_global_transform().basis.z, Vector3.UP)


func explode():
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.add_to_group("missile_explosions")
	explosion_instance.set_transform(Transform(Basis.IDENTITY, get_transform().origin))
	get_parent().add_child(explosion_instance)
	PoolManager.request(PoolManager.BOMB_EXPLOSION, get_global_transform().origin)
	queue_free()


func on_AnimationPlayer_animation_finished(_animation_name):
	start_basis = get_global_transform().basis.orthonormalized()
	apply_central_impulse(-get_global_transform().basis.z * SPEED * 5)
	if Globals.player_ship != null:
		target_pos = Globals.player_ship.get_global_transform().origin
		target_pos += Globals.player_ship.get_global_transform().basis.y.normalized() * .288
		guidance_update_timer.start(GUIDANCE_UPDATE_RATE)


func on_body_entered(body):
	.on_body_entered(body)
	if get_collision_exceptions().has(body) or body == self:
		return
	if body.is_in_group("projectiles"):
		gravity_scale = .3
	else:
		explode()


func on_GuidanceUpdateTimer_timeout():
	apply_central_impulse(-get_global_transform().basis.z.normalized() * SPEED * 2 * GUIDANCE_UPDATE_RATE)
	
	target_pointer.look_at(target_pos, Vector3.UP)
	var target_dir = -target_pointer.get_global_transform().basis.orthonormalized().z
	var current_dir = -get_global_transform().basis.orthonormalized().z
	
	var hor_target_dir = Vector2(target_dir.x, target_dir.z)
	var hor_current_dir = Vector2(current_dir.x, current_dir.z)
	var hor_angle_to_target = hor_current_dir.angle_to(hor_target_dir)
	var target_clockwise_speed = lerp(-MAX_TURN_SPEED, MAX_TURN_SPEED, hor_angle_to_target / PI * .5 + .5)
	var current_clockwise_speed = -get_angular_velocity().y
	if abs(current_clockwise_speed - target_clockwise_speed) < INACCURACY_TOLERANCE:
		left_exhaust_flame.set_visible(false)
		right_exhaust_flame.set_visible(false)
	elif current_clockwise_speed < target_clockwise_speed:
		apply_torque_impulse(start_basis.y * -TURN_FORCE * GUIDANCE_UPDATE_RATE)
		left_exhaust_flame.set_visible(true)
		right_exhaust_flame.set_visible(false)
	else:
		apply_torque_impulse(start_basis.y * TURN_FORCE * GUIDANCE_UPDATE_RATE)
		right_exhaust_flame.set_visible(true)
		left_exhaust_flame.set_visible(false)
	
	if not VERTICAL_GUIDANCE:
		return
	
	var ver_target_dir = Vector2(target_dir.y, target_dir.z)
	var ver_current_dir = Vector2(current_dir.y, current_dir.z)
	var ver_angle_to_target = ver_current_dir.angle_to(ver_target_dir)
	var target_backflip_speed = lerp(-MAX_TURN_SPEED, MAX_TURN_SPEED, ver_angle_to_target / PI * .5 + .5)
	var current_backflip_speed = get_angular_velocity().x
	if abs(current_backflip_speed - target_backflip_speed) < INACCURACY_TOLERANCE:
		top_exhaust_flame.set_visible(false)
		bottom_exhaust_flame.set_visible(false)
	elif current_backflip_speed < target_backflip_speed:
		apply_torque_impulse(Vector3.RIGHT * TURN_FORCE * GUIDANCE_UPDATE_RATE)
		bottom_exhaust_flame.set_visible(true)
		top_exhaust_flame.set_visible(false)
	else:
		apply_torque_impulse(Vector3.RIGHT * -TURN_FORCE * GUIDANCE_UPDATE_RATE)
		top_exhaust_flame.set_visible(true)
		bottom_exhaust_flame.set_visible(false)
