extends KinematicBody

signal released(progress)

export var windup_speed = 3.0
export var release_speed = 10.0
export var max_distance = 5.0

var start_pos = Vector3()
var	max_pos = Vector3()
var start_transform 
var max_transform
var move_progress = 0.0
var is_at_start = true

func _ready():
	start_pos = get_translation()
	max_pos = start_pos + get_transform().basis.z.normalized() * max_distance
	start_transform = Transform(Basis.IDENTITY, start_pos)
	max_transform = Transform(Basis.IDENTITY, max_pos)
	

func _physics_process(delta):
	if Input.is_action_pressed("plunger"):
		if move_progress < 1:
			move_progress += windup_speed / max_distance * delta
	elif move_progress > 0:
		move_progress -= release_speed / max_distance * delta
		if move_progress < 0:
			move_progress = 0
	
	if Input.is_action_just_released("plunger"):
		emit_signal("released", move_progress)
	
	#set_translation(start_pos.linear_interpolate(max_pos, move_progress))
	set_transform(start_transform.interpolate_with(max_transform, move_progress))
		
