extends KinematicBody

export var windup_speed = 3.0
export var release_speed = 10.0
export var max_distance = 5.0

var start_pos = Vector3()
var	max_pos = Vector3()
var move_progress = 0.0
var is_at_start = true

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = get_translation()
	max_pos = start_pos + get_transform().basis.z.normalized() * max_distance

func _physics_process(delta):
	if Input.is_action_pressed("ui_down"):
		if move_progress < 1:
			move_progress += windup_speed / max_distance * delta

	#if plunger is released, move forward until start_pos is behind plunger
	elif move_progress > 0:
		move_progress -= release_speed / max_distance * delta
		if move_progress < 0:
			move_progress = 0
	
	set_translation(start_pos.linear_interpolate(max_pos, move_progress))
		
