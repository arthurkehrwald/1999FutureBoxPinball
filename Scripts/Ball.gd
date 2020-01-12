extends RigidBody

signal teleport_physics_cooldown_buffer_expired
signal physics_debug_info_update(speed, gravity)

export var airborne_gravity_scale_multiplier = .1
var is_airborne = false
var raycast = RayCast

var start_pos = Vector3()
var teleporting = false
var teleport_physics_cooldown_time_remaining = 0

# for setting gravity scale based on speed
const TELEPORT_PHYSICS_COOLDOWN_BUFFER = .02
const GRAVITY_SCALE_CALCULATION_SPEED_VALUE_SAMPLE_SIZE = 1
const GRAVITY_CHANGE_RATE = 1
var recorded_speeds = []
var target_gravity_scale = 10

func _enter_tree():
	GameState.connect("toggle_nightmode", self, "_on_GameState_toggle_nightmode")
	start_pos = get_global_transform().origin

func _ready():
	GameState.connect("global_reset", self, "_on_GameState_reset_ball")
	GameState.connect("reset_ball", self,"_on_GameState_reset_ball")
	raycast = get_node("../BallRayCast")
	set_process(false)
	
func _on_GameState_reset_ball():
	teleport(start_pos)
	
# teleport function is from:
# https://github.com/markopolojorgensen/godot_2d_camera_limiter/blob/all_addons/addons/movement/teleporter.gd
func teleport(destination):
	if teleporting:
		return
	
	teleporting = true
	set_physics_process(false)
	
	teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	var t = get_transform()
	t.origin = destination
	set_global_transform(t)
	
	teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	set_physics_process(true)
	set_sleeping(false)
	teleporting = false

func _process(delta):
	teleport_physics_cooldown_time_remaining -= delta
	if teleport_physics_cooldown_time_remaining <= 0:
		set_process(false)
		emit_signal("teleport_physics_cooldown_buffer_expired")
	
func _on_GameState_toggle_nightmode(toggle):
	if toggle:
		$OmniLight.show()
	else:
		$OmniLight.hide()

func _physics_process(delta):
	if is_airborne == raycast.is_colliding():
		is_airborne = !is_airborne
		if is_airborne:
			gravity_scale *= airborne_gravity_scale_multiplier
			emit_signal("physics_debug_info_update", 1, 0)
			print("takeoff")
		else:
			gravity_scale /= airborne_gravity_scale_multiplier
			emit_signal("physics_debug_info_update", 0, 1)
			print("landed")	
			
	
func set_gravity_scale_based_on_speed(delta):
	if recorded_speeds.size() < GRAVITY_SCALE_CALCULATION_SPEED_VALUE_SAMPLE_SIZE:
		recorded_speeds.append(linear_velocity.length())
	else:
		var speeds_sum = 0
		var speeds_avg = 0
		for s in recorded_speeds:
			speeds_sum += s
		speeds_avg = speeds_sum / recorded_speeds.size()
		target_gravity_scale = clamp(-.4 * pow(.17 * speeds_avg, 3) + 10, 1, 10)
		#gravity_scale = clamp(-.7 * linear_velocity.length() + 10, 2, 20)
		#gravity_scale = clamp(4.6 * pow(.4 * speeds_avg, - .6) - .4, 1, 12)
		#gravity_scale = clamp(1.7 * pow(.1 * speeds_avg, -1.88) + 2, 2, 15)
		var gravity_scale_adjustment = target_gravity_scale - gravity_scale
		if abs(gravity_scale_adjustment) > GRAVITY_CHANGE_RATE * delta:
			if sign(gravity_scale_adjustment):
				gravity_scale += GRAVITY_CHANGE_RATE * delta 
			else:
				gravity_scale -= GRAVITY_CHANGE_RATE * delta
		else:
			gravity_scale = target_gravity_scale
		gravity_scale = clamp(-.4 * pow(.17 * speeds_avg, 3) + 10, 1, 10)
		emit_signal("physics_debug_info_update", speeds_avg, gravity_scale)
		recorded_speeds.clear()
