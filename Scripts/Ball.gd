extends RigidBody

signal teleport_physics_cooldown_buffer_expired

const TELEPORT_PHYSICS_COOLDOWN_BUFFER = .02

var start_pos = Vector3()
var teleporting = false
var teleport_physics_cooldown_time_remaining = 0

func _ready():
	start_pos = get_transform().origin
	GameState.connect("reset_ball", self,"_on_GameState_reset_ball")
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
	teleporting = false

func _process(delta):
	teleport_physics_cooldown_time_remaining -= delta
	if teleport_physics_cooldown_time_remaining <= 0:
		set_process(false)
		emit_signal("teleport_physics_cooldown_buffer_expired")
		

