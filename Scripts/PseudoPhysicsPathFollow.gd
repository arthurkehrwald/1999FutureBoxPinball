extends PathFollow

signal debug_info_update(angle, speed, acceleration)

var looping_body = null
var looping_body_is_bomb = false
var speed = 0

enum states {NONE, AT_ENTRANCE, AT_EXIT}
var looping_body_waiting_status = states.NONE
var looping_body_entered_status = states.NONE

var entrance_transform = Transform()
var exit_transform = Transform()
var entrance_area = Area
var exit_area = Area
var timer = Timer

const MIN_START_PROXIMITY = .1

export var start_velocity_multiplier = 1 # not zero
export var gravity = 15
export var resistance = 2
export var friction = .6
export var allow_exit_as_entrance = false

const SPEED_ROTATION_RATE = 6
	
func _ready():
	entrance_area = get_node("../EntranceArea")
	exit_area = get_node("../ExitArea")
	entrance_transform = entrance_area.get_global_transform()
	exit_transform = exit_area.get_global_transform()
	set_physics_process(false)
	if !allow_exit_as_entrance:
		exit_area.set_monitorable(false)
		exit_area.set_monitoring(false)
	
func _on_EntranceArea_body_entered(body):
	if looping_body == null:
		var angle_factor = max(0, -.3 * pow(body.get_linear_velocity().angle_to(entrance_transform.basis.z), 3) + 1)
		print("WireRamp: angle_factor - ", angle_factor)
		speed = angle_factor * body.get_linear_velocity().length() * start_velocity_multiplier
		if speed > 0:
			looping_body = body
			looping_body.delayed_teleport(entrance_transform.origin)
			set_unit_offset(0.0)
			looping_body_waiting_status = states.AT_ENTRANCE
			looping_body_entered_status = states.AT_ENTRANCE
			start_follow()
			
func _on_ExitArea_body_entered(body):
	if looping_body == null:
		var angle_factor = max(0, -.3 * pow(body.get_linear_velocity().angle_to(exit_transform.basis.z), 3) + 1)
		print("WireRamp: angle_factor - ", angle_factor)
		speed = angle_factor * body.get_linear_velocity().length() * -start_velocity_multiplier
		if speed < 0:
			looping_body = body
			looping_body.delayed_teleport(exit_transform.origin)
			set_unit_offset(1.0)
			looping_body_waiting_status = states.AT_EXIT
			looping_body_entered_status = states.AT_EXIT
			start_follow()

func _physics_process(delta):
	var incline = Vector3(0, 0, 1).angle_to(-get_global_transform().basis.z)
	if incline > PI / 2:
		incline -= (incline - PI / 2) * 2
	incline /= PI / 2
	var point_ahead = get_global_transform().origin + get_global_transform().basis.z.normalized()
	if point_ahead.y < get_global_transform().origin.y:
		incline = -incline
		
	var acceleration = -incline * gravity
	acceleration *= .8 * pow(abs(incline) + .01, -1) + .2 
	if abs(acceleration) < resistance:
		acceleration = 0
	else:
		acceleration -= resistance * sign(acceleration)
	
	if looping_body != null:
		speed += acceleration * delta
		speed *= 1 - friction * delta
		var reached_entrance = speed < 0 and get_unit_offset() == 0
		var reached_exit = speed > 0 and get_unit_offset() == 1
		if reached_exit or reached_entrance:
			looping_body.set_locked(false)
			print("Wire Ramp finished")
			if reached_exit:
				looping_body.apply_central_impulse(-exit_transform.basis.z.normalized() * speed / start_velocity_multiplier)
			if reached_entrance:
				looping_body.apply_central_impulse(-entrance_transform.basis.z.normalized() * -speed / start_velocity_multiplier)
			reset(true)
		else:
			set_offset(get_offset() + speed * delta)
			if looping_body_is_bomb:
				$BombReplica.rotate_x(speed * SPEED_ROTATION_RATE * delta)
			else:
				$BallReplica.rotate_x(speed * SPEED_ROTATION_RATE * delta)
			if looping_body_waiting_status == states.AT_ENTRANCE and get_unit_offset() > .6:
				looping_body.delayed_teleport(exit_transform.origin)
				looping_body_waiting_status = states.AT_EXIT
			elif looping_body_waiting_status == states.AT_EXIT and get_unit_offset() < .4:
				looping_body.delayed_teleport(entrance_transform.origin)
				looping_body_waiting_status = states.AT_ENTRANCE
	elif looping_body_is_bomb:
		#that means the bomb exploded while it was on the rail
		reset(true)
	emit_signal("debug_info_update", incline, speed, acceleration)
		
func start_follow():
	if looping_body == null:
		print("looping body is null")
	looping_body.set_visible(false)
	looping_body.set_locked(true)
	if looping_body.get_collision_layer() == 1:
		$BallReplica.set_visible(true)
		looping_body_is_bomb = false
	else:
		$BombReplica.set_visible(true)
		looping_body_is_bomb = true
	entrance_area.set_deferred("monitoring", false)
	entrance_area.set_deferred("monitorable", false)
	exit_area.set_deferred("monitoring", false)
	exit_area.set_deferred("monitorable", false)
	print("wire ramp: start follow")
	set_physics_process(true)

func reset(is_active):
	set_physics_process(false)
	set_unit_offset(0.0)
	$BallReplica.set_visible(false)
	$BombReplica.set_visible(false)
	entrance_area.set_deferred("monitoring", is_active)
	entrance_area.set_deferred("monitorable", is_active)
	exit_area.set_deferred("monitoring", is_active and allow_exit_as_entrance)
	exit_area.set_deferred("monitorable", is_active and allow_exit_as_entrance)
	if looping_body != null:
		looping_body_waiting_status = states.NONE
		looping_body_entered_status = states.NONE
		looping_body.set_visible(true)
		looping_body.set_locked(false)
		looping_body = null
	speed = 0
