extends PathFollow

signal debug_info_update(angle, speed, acceleration)

export var looping_louie_trigger_progress = .5

var looping_body = null
var looping_body_is_bomb = false
var speed = 0
var looping_body_is_waiting_at_entrance = false
var looping_body_entered_at_entrance = false
var looping_body_exited_at_entrance = false
var entrance_transform = Transform()
var exit_transform = Transform()
var timer = Timer

const MIN_START_PROXIMITY = .1

const START_VELOCITY_MULTIPLIER = 1 # not zero
const GRAVITY = 15
const RESISTANCE = 2
const FRICTION = .6

const SPEED_ROTATION_RATE = 6

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _ready():
	entrance_transform = get_node("../").get_node("EntranceArea").get_global_transform()
	exit_transform = get_node("../").get_node("ExitArea").get_global_transform()
	set_physics_process(false)
	
func _on_EntranceArea_body_entered(body):
	if looping_body == null:
		var angle_factor = max(0, -.3 * pow(body.get_linear_velocity().angle_to(-entrance_transform.basis.z), 3) + 1)
		print(angle_factor)
		speed = angle_factor * body.get_linear_velocity().length() * START_VELOCITY_MULTIPLIER
		if speed > 0:
			set_unit_offset(0.0)
			looping_body = body
			looping_body_is_waiting_at_entrance = true
			looping_body_entered_at_entrance = true
			body.set_visible(false)
			body.set_locked(true)
			if body.get_collision_layer() == 1:
				$BallReplica.set_visible(true)
				looping_body_is_bomb = false
			else:
				$BombReplica.set_visible(true)
				looping_body_is_bomb = true
			set_physics_process(true)
			
			
func _on_ExitArea_body_entered(body):
	if looping_body == null:
		var angle_factor = max(0, -.3 * pow(body.get_linear_velocity().angle_to(-exit_transform.basis.z), 3) + 1)
		print(angle_factor)
		speed = angle_factor * body.get_linear_velocity().length() * -START_VELOCITY_MULTIPLIER
		if speed < 0:
			set_unit_offset(1.0)
			looping_body = body
			looping_body_is_waiting_at_entrance = false
			looping_body_entered_at_entrance = false
			body.set_visible(false)
			body.set_locked(true)
			if body.get_collision_layer() == 1:
				$BallReplica.set_visible(true)
			else:
				$BombReplica.set_visible(true)
				looping_body_is_bomb = true
			set_physics_process(true)

func _on_EntranceArea_body_exited(body):
	if looping_body != null and looping_body_exited_at_entrance:
		looping_body = null

func _on_ExitArea_body_exited(body):
	if looping_body != null and !looping_body_exited_at_entrance:
		looping_body = null

func _physics_process(delta):
	var incline = Vector3(0, 0, 1).angle_to(-get_global_transform().basis.z)
	if incline > PI / 2:
		incline -= (incline - PI / 2) * 2
	incline /= PI / 2
	var point_ahead = get_global_transform().origin + get_global_transform().basis.z.normalized()
	if point_ahead.y < get_global_transform().origin.y:
		incline = -incline
		
	var acceleration = -incline * GRAVITY
	acceleration *= .8 * pow(abs(incline) + .01, -1) + .2 
	if abs(acceleration) < RESISTANCE:
		acceleration = 0
	else:
		acceleration -= RESISTANCE * sign(acceleration)
	
	if looping_body != null:
		speed += acceleration * delta
		speed *= 1 - FRICTION * delta
		var reached_entrance = speed < 0 and get_unit_offset() == 0
		var reached_exit = speed > 0 and get_unit_offset() == 1
		if reached_exit or reached_entrance:
			looping_body.set_locked(false)
			looping_body.set_visible(true)
			if reached_exit:
				looping_body_exited_at_entrance = false
				#looping_body.teleport(exit_transform.origin, false, exit_transform.basis.z.normalized() * speed / START_VELOCITY_MULTIPLIER)
				looping_body.apply_central_impulse(exit_transform.basis.z.normalized() * speed / START_VELOCITY_MULTIPLIER)
			if reached_entrance:
				looping_body_exited_at_entrance = true
				#looping_body.teleport(entrance_transform.origin, false, -entrance_transform.basis.z.normalized() * speed / START_VELOCITY_MULTIPLIER)
				looping_body.apply_central_impulse(-entrance_transform.basis.z.normalized() * speed / START_VELOCITY_MULTIPLIER)
			$BallReplica.set_visible(false)
			$BombReplica.set_visible(false)
			set_physics_process(false)
		else:
			set_offset(get_offset() + speed * delta)
			if looping_body_is_bomb:
				$BombReplica.rotate_x(speed * SPEED_ROTATION_RATE * delta)
			else:
				$BallReplica.rotate_x(speed * SPEED_ROTATION_RATE * delta)
			if looping_body_is_waiting_at_entrance and get_unit_offset() > .6:
				looping_body.teleport(exit_transform.origin, false, Vector3(0, 0, 0))
				looping_body_is_waiting_at_entrance = false
			elif !looping_body_is_waiting_at_entrance and get_unit_offset() < .4:
				looping_body.teleport(entrance_transform.origin, false, Vector3(0, 0, 0))
				looping_body_is_waiting_at_entrance = true
	elif looping_body_is_bomb:
		#that means the bomb exploded while it was on the rail
		reset()
	emit_signal("debug_info_update", incline, speed, acceleration)
		
func _on_GameState_global_reset():
	reset()

func reset():
	print("loop reset")
	set_physics_process(false)
	set_unit_offset(0.0)
	$BallReplica.set_visible(false)
	$BombReplica.set_visible(false)
	if looping_body != null:
		looping_body.set_visible(true)
		looping_body = null
	speed = 0
