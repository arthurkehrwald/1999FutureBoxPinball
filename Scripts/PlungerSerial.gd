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
	
	move_progress = $PortReader.normalizedData
	set_translation(start_pos.linear_interpolate(max_pos, move_progress))
		
