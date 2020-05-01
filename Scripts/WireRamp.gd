extends Path

enum states {NONE, AT_ENTRANCE, AT_EXIT}

const SPEED_ROTATION_RATE = 4

export var start_velocity_multiplier = 1 # not zero
export var gravity = 14.0
export var resistance = .3
export var friction = .2
export var allow_exit_as_entrance = false

var looping_body = null
var looping_body_is_bomb = false
var speed = 0
var looping_body_waiting_status = states.NONE
var looping_body_entered_status = states.NONE
var looping_body_mesh = null

onready var path_follow = get_node("PathFollow")
onready var entrance_area = get_node("EntranceArea")
onready var exit_area = get_node("ExitArea")
onready var ball_replica = get_node("PathFollow/BallReplica")
onready var bomb_replica = get_node("PathFollow/BombReplica")
#onready var debug_label = get_node("DebugLabel")

func _ready():
	entrance_area.connect("body_entered", self, "on_EntranceArea_body_entered")
	if allow_exit_as_entrance:
		exit_area.connect("body_entered", self, "on_ExitArea_body_entered")
	set_physics_process(false)


func on_EntranceArea_body_entered(body):
	if looping_body != null or not body.is_in_group("rollers"):
		return
	var angle_factor = max(0, -.3 * pow(body.get_linear_velocity().angle_to(entrance_area.get_global_transform().basis.z), 3) + 1)
	speed = angle_factor * body.get_linear_velocity().length() * start_velocity_multiplier
	if speed > 0:
		looping_body = weakref(body)
		looping_body.get_ref().teleport(entrance_area.get_global_transform().origin)
		path_follow.set_unit_offset(0.0)
		looping_body_waiting_status = states.AT_ENTRANCE
		looping_body_entered_status = states.AT_ENTRANCE
		start_follow()


func on_ExitArea_body_entered(body):
	if looping_body == null:
		var angle_factor = max(0, -.3 * pow(body.get_linear_velocity().angle_to(exit_area.get_global_transform().basis.z), 3) + 1)
		speed = angle_factor * body.get_linear_velocity().length() * -start_velocity_multiplier
		if speed < 0:
			looping_body = weakref(body)
			looping_body.get_ref().teleport(exit_area.get_global_transform().origin)
			path_follow.set_unit_offset(1.0)
			looping_body_waiting_status = states.AT_EXIT
			looping_body_entered_status = states.AT_EXIT
			start_follow()


func _physics_process(delta):
	var incline = Vector3(0, 0, 1).angle_to(-path_follow.get_global_transform().basis.z)
	if incline > PI / 2:
		incline -= (incline - PI / 2) * 2
	incline /= PI / 2
	var point_ahead = path_follow.get_global_transform().origin + path_follow.get_global_transform().basis.z.normalized()
	if point_ahead.y < path_follow.get_global_transform().origin.y:
		incline = -incline
	
	var acceleration = -incline * gravity
	acceleration *= .8 * pow(abs(incline) + .01, -1) + .2 
	if abs(acceleration) < resistance:
		acceleration = 0
	else:
		acceleration -= resistance * sign(acceleration)
	
	if looping_body.get_ref():
		speed += acceleration * delta
		speed *= 1 - friction * delta
		var reached_entrance = speed < 0 and path_follow.get_unit_offset() == 0
		var reached_exit = speed > 0 and path_follow.get_unit_offset() == 1
		if reached_exit or reached_entrance:
			path_follow.remove_child(looping_body_mesh)
			looping_body.get_ref().add_child(looping_body_mesh)
			looping_body.get_ref().set_locked(false)
			var impulse_dir = Vector3.ZERO
			var impulse = Vector3.ZERO
			if reached_exit:
				impulse_dir = -exit_area.get_global_transform().basis.z.normalized()
				impulse = impulse_dir * speed / start_velocity_multiplier
			if reached_entrance:
				impulse_dir = -entrance_area.get_global_transform().basis.z.normalized()
				impulse = impulse_dir * -speed / start_velocity_multiplier
			looping_body.get_ref().apply_central_impulse(impulse)
			reset(true)
		else:
			path_follow.set_offset(path_follow.get_offset() + speed * delta)
			looping_body_mesh.rotate_x(speed * SPEED_ROTATION_RATE * delta)
#			if looping_body_is_bomb:
#				bomb_replica.rotate_x(speed * SPEED_ROTATION_RATE * delta)
#			else:
#				ball_replica.rotate_x(speed * SPEED_ROTATION_RATE * delta)
			if looping_body_waiting_status == states.AT_ENTRANCE and path_follow.get_unit_offset() > .6:
				looping_body.get_ref().teleport(exit_area.get_global_transform().origin)
				looping_body_waiting_status = states.AT_EXIT
			elif looping_body_waiting_status == states.AT_EXIT and path_follow.get_unit_offset() < .4:
				looping_body.get_ref().teleport(entrance_area.get_global_transform().origin)
				looping_body_waiting_status = states.AT_ENTRANCE
	else:
		#that means the bomb exploded while it was on the rail
		reset(true)
	#debug_label.display_debug_info(rad2deg(incline), speed, acceleration)


func start_follow():
	if looping_body.get_ref().is_in_group("pinballs"):
		#ball_replica.set_visible(true)
		looping_body_is_bomb = false
	elif looping_body.get_ref().is_in_group("bombs"):
		#bomb_replica.set_visible(true)
		looping_body_is_bomb = true
	else:
		push_error("WireRamp: Body with name: " + looping_body.get_ref().name
		+ "entered that is in group 'rollers', but neither in group 'pinballs'"
		+ " nor in group 'bombs.' Check groups")
		looping_body = null
		return
	looping_body_mesh = looping_body.get_ref().get_node("MeshInstance")
	looping_body_mesh.get_parent().remove_child(looping_body_mesh)
	path_follow.add_child(looping_body_mesh)
	looping_body.get_ref().set_visible(false)
	looping_body.get_ref().set_locked(true)
	entrance_area.set_deferred("monitoring", false)
	entrance_area.set_deferred("monitorable", false)
	exit_area.set_deferred("monitoring", false)
	exit_area.set_deferred("monitorable", false)
	set_physics_process(true)


func reset(is_active):
	set_physics_process(false)
	path_follow.set_unit_offset(0.0)
	#ball_replica.set_visible(false)
	#bomb_replica.set_visible(false)
	entrance_area.set_deferred("monitoring", is_active)
	entrance_area.set_deferred("monitorable", is_active)
	exit_area.set_deferred("monitoring", is_active)
	exit_area.set_deferred("monitorable", is_active)
	looping_body_mesh = null
	if looping_body != null:
		if looping_body.get_ref():
			looping_body_waiting_status = states.NONE
			looping_body_entered_status = states.NONE
			looping_body.get_ref().set_visible(true)
			looping_body.get_ref().set_locked(false)
		looping_body = null
	speed = 0
