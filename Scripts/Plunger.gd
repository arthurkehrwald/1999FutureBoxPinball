extends KinematicBody

signal released(progress)

export var windup_speed = 3.0
export var release_speed = 10.0
export var max_distance = 5.0

var start_pos = Vector3()
var	max_pos = Vector3()
var move_progress = 0.0
var is_at_start = true

func _ready():
	start_pos = get_translation()
	max_pos = start_pos + get_transform().basis.z.normalized() * max_distance

func _physics_process(delta):
	if Input.is_action_pressed("plunger"):
		if move_progress < 1:
			move_progress += windup_speed / max_distance * delta
	elif move_progress > 0:
		move_progress -= release_speed / max_distance * delta
		if move_progress < 0:
			move_progress = 0
	GameState.plunger_progress = move_progress
	
	if Input.is_action_just_released("plunger"):
		emit_signal("released", move_progress)
	
	set_translation(start_pos.linear_interpolate(max_pos, move_progress))
		
