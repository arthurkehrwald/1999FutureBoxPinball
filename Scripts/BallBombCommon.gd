extends RigidBody

signal teleport_physics_cooldown_buffer_expired
signal physics_debug_info_update(speed, gravity)

export var airborne_gravity_scale_multiplier = .4
export var speed_based_gravity_scale = false

var is_airborne = false
var raycast = RayCast

var start_pos = Vector3()
var teleporting = false
var teleport_physics_cooldown_time_remaining = 0

const TELEPORT_PHYSICS_COOLDOWN_BUFFER = .02

func _enter_tree():
	GameState.connect("toggle_nightmode", self, "_on_GameState_toggle_nightmode")

func _ready():
	raycast = get_node("../StuckToRigidbody/RayCast")
	set_process(false)
	
func teleport(destination, maintain_velocity, impulse_on_exit):
	print("BallBombCommon: teleporting to - ", destination)
	
	var t = get_transform()
	t.origin = destination
	set_global_transform(t)

	set_sleeping(false)
	if !maintain_velocity:
		set_linear_velocity(Vector3(0,0,0))
		set_angular_velocity(Vector3(0,0,0))
	apply_central_impulse(impulse_on_exit)
	
func delayed_teleport(destination, impulse_on_exit = Vector3(0, 0, 0)):
	if teleporting:
		return
	
	teleporting = true
	set_physics_process(false)
	
	teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	var t = get_global_transform()
	t.origin = destination
	set_global_transform(t)
	
	teleport_physics_cooldown_time_remaining = TELEPORT_PHYSICS_COOLDOWN_BUFFER
	set_process(true)
	yield(self, "teleport_physics_cooldown_buffer_expired")
	
	set_physics_process(true)
	teleporting = false
	
	set_linear_velocity(Vector3(0,0,0))
	set_angular_velocity(Vector3(0,0,0))
	apply_central_impulse(impulse_on_exit)
	
func set_locked(is_locked):
	axis_lock_linear_x = is_locked
	axis_lock_linear_y = is_locked
	axis_lock_linear_z = is_locked
	axis_lock_angular_x = is_locked
	axis_lock_angular_y = is_locked
	axis_lock_angular_z = is_locked

func _process(delta):
	teleport_physics_cooldown_time_remaining -= delta
	if teleport_physics_cooldown_time_remaining <= 0:
		set_process(false)
		emit_signal("teleport_physics_cooldown_buffer_expired")
	
func _on_GameState_toggle_nightmode(toggle):
	if toggle:
		$OmniLight.hide()
	else:
		$OmniLight.hide()

func _physics_process(_delta):
	if is_airborne == raycast.is_colliding():
		is_airborne = !is_airborne
		if is_airborne:
			gravity_scale *= airborne_gravity_scale_multiplier
			emit_signal("physics_debug_info_update", 1, 0)
		else:
			gravity_scale /= airborne_gravity_scale_multiplier
			emit_signal("physics_debug_info_update", 0, 1)
	if speed_based_gravity_scale and !is_airborne:
		set_gravity_scale_based_on_speed()
	
func set_gravity_scale_based_on_speed():
		#gravity_scale = clamp(-.2 * pow(.2 * get_linear_velocity().length(), 2.7) + 15, 1, 20)
		gravity_scale = -get_linear_velocity().length() + 20
		emit_signal("physics_debug_info_update", get_linear_velocity().length(), gravity_scale)