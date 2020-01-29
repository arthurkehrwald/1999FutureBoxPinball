extends Spatial

export var max_turn_angle = 45
export var turn_speed = .5
export var max_shot_speed = 50

var start_transform = Transform()
var min_transform  = Transform()
var max_transform = Transform()
var rotation_progress = 0.5
var ball_to_shoot
var teleporter_entrance
var dotted_line_start_transform = Transform()
var has_shot = false

var ball_scene = preload("res://Scenes/Ball.tscn")

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	start_transform = get_transform()
	min_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(-max_turn_angle))
	max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(max_turn_angle))
	dotted_line_start_transform = $TeleporterExit/DottedLine.get_transform()
	$TeleporterExit/DottedLine.set_visible(false)
	set_process(false)

func _process(delta):
	if has_shot:
		if rotation_progress == .5:
			set_process(false)
		elif rotation_progress < .5:
			rotation_progress = min(.5, rotation_progress + turn_speed * delta)
		else:
			rotation_progress = max(.5, rotation_progress - turn_speed * delta)
	else:
		if Input.is_action_pressed("turret_right"):
			if rotation_progress > 0:
				rotation_progress -= turn_speed * delta
		if Input.is_action_pressed("turret_left"):
			if rotation_progress < 1:
				rotation_progress += turn_speed * delta
		
		if $TeleporterExit/DottedLine.visible:
			$TeleporterExit/DottedLine.set_transform(dotted_line_start_transform.scaled(Vector3(1, 1, lerp(.25, .8, GameState.plunger_progress))))
		elif Input.is_action_just_pressed("plunger"):
			$TeleporterExit/DottedLine.set_transform(dotted_line_start_transform.scaled(Vector3(1, 1, lerp(.25, .8, GameState.plunger_progress))))
			$TeleporterExit/DottedLine.set_visible(true)
			
	var new_rotation = Quat(min_transform.basis.slerp(max_transform.basis.orthonormalized(), rotation_progress))
	set_transform(Transform(new_rotation, get_transform().origin))	
	
	
func _on_TeleporterEntrance_ball_entered(ball, _teleporter_entrance):
	_teleporter_entrance.set_active(false)
	teleporter_entrance = _teleporter_entrance
	ball.set_visible(false)
	ball.set_locked(true)
	ball.delayed_teleport($TeleporterExit.get_global_transform().origin)
	ball_to_shoot = ball
	has_shot = false
	set_process(true)
	
func _on_ShopMenu_bought_turret_shot():
	var ball_instance = ball_scene.instance()
	get_node("/root/Main").add_child(ball_instance)
	ball_instance.get_node("Rigidbody").set_visible(false)
	ball_instance.get_node("Rigidbody").set_locked(true)
	ball_instance.get_node("Rigidbody").delayed_teleport($TeleporterExit.get_global_transform().origin)
	ball_to_shoot = ball_instance.get_node("Rigidbody")
	GameState.balls_on_field += 1
	has_shot = false
	set_process(true)

func _on_Plunger_released(progress):
	if is_processing():
		shoot(progress)
		
func shoot(plunger_progress):
	$TeleporterExit/DottedLine.set_visible(false)
	if teleporter_entrance != null:
		teleporter_entrance.set_active(true)
	ball_to_shoot.set_locked(false)
	ball_to_shoot.set_visible(true)
	var plunger_force = .15 * pow(plunger_progress - 1.7, 3) + 1
	print(plunger_force)
	ball_to_shoot.apply_central_impulse(-$TeleporterExit.get_global_transform().basis.z.normalized() * max_shot_speed * plunger_force)
	has_shot = true

func _on_GameState_global_reset(is_init):
	print("Turret global reset")
	$TeleporterExit/DottedLine.set_visible(false)
	ball_to_shoot = null
	has_shot = false
	if !is_init:
		set_process(false)
		var start_rotation = Quat(start_transform.basis.orthonormalized())
		set_transform(Transform(start_rotation, get_transform().origin))	
