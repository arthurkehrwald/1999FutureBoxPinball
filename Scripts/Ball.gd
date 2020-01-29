extends "res://Scripts/BallBombCommon.gd"
	
export var remote_control_strength = 1.0
	
var is_remote_controlled = false	
var is_remote_control_blocked = false

var remote_control_timer = Timer
var remote_control_time_bar = Sprite3D

func _ready():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	remote_control_time_bar = get_node("../StuckToRigidbody/Bar3D")
	remote_control_time_bar.set_max_value(1.0)
	remote_control_timer = get_node_or_null("/root/Main/RemoteBallControlTimer")
	if remote_control_timer == null:
		print("Ball: could not find remote control timer")
		set_remote_controlled(false)
	else:
		remote_control_timer.connect("start", self, "_on_RemoteControlTimer_start")
		remote_control_timer.connect("timeout", self, "_on_RemoteControlTimer_timeout")
		remote_control_timer.connect("time_left_changed", remote_control_time_bar, "_on_value_changed")
		set_remote_controlled(!remote_control_timer.is_stopped())
		
func _physics_process(_delta):
	if is_remote_controlled and not is_remote_control_blocked:
		if Input.is_action_pressed("flipper_left") and not Input.is_action_pressed("flipper_right"):
			apply_central_impulse(Vector3(-1, 0, 0) * remote_control_strength * clamp(abs(linear_velocity.z) * .05, 0, 1))
		if Input.is_action_pressed("flipper_right") and not Input.is_action_pressed("flipper_left"):
			apply_central_impulse(Vector3(1, 0, 0) * remote_control_strength * clamp(abs(linear_velocity.z) * .05, 0, 1))
			
	
func back_to_spawn():
	set_locked(false)
	set_visible(true)
	teleport(start_pos, false, Vector3(.0,.0,.0))

func delete():
	GameState.balls_on_field -= 1
	owner.queue_free()
	
func set_remote_controlled(_is_remote_controlled):
	remote_control_time_bar.set_visible(_is_remote_controlled)
	is_remote_controlled = _is_remote_controlled
	print("Ball: remote control status - ", is_remote_controlled)
	
func set_remote_control_blocked(is_blocked):
	is_remote_control_blocked = is_blocked
		
func _on_GameState_global_reset(is_init):
	if !is_init:
		delete()

func _on_LaserTrex_hit():
	delete()

func _on_RemoteControlTimer_start():
	set_remote_controlled(true)

func _on_RemoteControlTimer_timeout():
	set_remote_controlled(false)
