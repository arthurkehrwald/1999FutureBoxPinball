extends Spatial

export var max_turn_angle = 45
export var turn_speed = .5
export var max_shot_speed = 50

signal was_loaded
signal has_shot

var start_transform = Transform()
var min_transform  = Transform()
var max_transform = Transform()
var rotation_progress = 0.5
var ball_to_shoot
var dotted_line_start_transform = Transform()

var ball_scene = preload("res://Scenes/Pinball.tscn")

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _ready():
	start_transform = get_transform()
	min_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(-max_turn_angle))
	max_transform = start_transform.rotated(get_transform().basis.y.normalized(), deg2rad(max_turn_angle))
	dotted_line_start_transform = $TeleporterExit/DottedLine.get_transform()
	$TeleporterExit/DottedLine.set_visible(false)
	set_process(false)

func _process(delta):
	if ball_to_shoot == null:
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

func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		$TeleporterExit/DottedLine.set_visible(false)
		ball_to_shoot = null
		set_process(false)
		var start_rotation = Quat(start_transform.basis.orthonormalized())
		set_transform(Transform(start_rotation, get_transform().origin))		

#func _on_TeleporterEntrance_ball_entered(ball):
#	if is_loaded:
#		print("Teleporter Entrance")
#		return
#	Announcer.say("turret_active")
#	ball.set_visible(false)
#	ball.set_locked(true)
#	ball.delayed_teleport($TeleporterExit.get_global_transform().origin)
#	ball_to_shoot = ball
#	is_loaded = true
#	emit_signal("was_loaded")
#	set_process(true)
#	delayed_announcer_instructions()

func _on_ShopMenu_bought_turret_shot():
	#print("Turret: on shop menu bought turret shot")
	var ball_instance = ball_scene.instance()
	get_node("/root/Main").add_child(ball_instance)
	insert_ball(ball_instance)
	
func insert_ball(ball):
	assert(ball.is_in_group("Pinballs"))
	if ball_to_shoot != null:
		shoot(.5)
	Announcer.say("turret_active")
	ball.set_visible(false)
	ball.set_locked(true)
	ball.delayed_teleport($TeleporterExit.get_global_transform().origin)
	ball_to_shoot = ball
	emit_signal("was_loaded")
	set_process(true)
	delayed_announcer_instructions()
	
		
func shoot(plunger_progress):
	if ball_to_shoot == null:
		return
	$TeleporterExit/DottedLine.set_visible(false)
	ball_to_shoot.set_locked(false)
	ball_to_shoot.set_visible(true)
	var plunger_force = .15 * pow(plunger_progress - 1.7, 3) + 1
	#print(plunger_force)
	ball_to_shoot.apply_central_impulse(-$TeleporterExit.get_global_transform().basis.z.normalized() * max_shot_speed * plunger_force)
	ball_to_shoot = null
	emit_signal("has_shot")

func delayed_announcer_instructions():
	yield(get_tree().create_timer(2.0), "timeout")
	if ball_to_shoot != null:
		Announcer.say("plunger_fire")
