extends KinematicBody

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

onready var com=$Com 

var port
var number
var output
var intData = 0;
var data = ""

export var windup_speed = 3.0
export var release_speed = 10.0
export var max_distance = 5.0

var start_pos = Vector3()
var	max_pos = Vector3()
var move_progress = 0.0
var is_at_start = true
var pos;

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	PORT.close()
	PORT.open("COM3", 9600, 1000)
	set_physics_process(true)
	
	
	start_pos = get_translation()
	max_pos = start_pos + get_transform().basis.z.normalized() * max_distance

func _physics_process(delta):
	var vector_to_start_pos = start_pos - get_global_transform().origin
	var to_start_dot_forward = vector_to_start_pos.normalized().dot(get_global_transform().basis.x.normalized())

	if Input.is_action_pressed("ui_down"):
		if move_progress < 1:
			move_progress += windup_speed / max_distance * delta
			#global_translate(-get_global_transform().basis.x.normalized() * windup_speed * delta)
			#is_at_start = false
	#if plunger is released, move forward until start_pos is behind plunger
	elif move_progress > 0:
		move_progress -= release_speed / max_distance * delta
		if move_progress < 0:
			move_progress = 0
		#if to_start_dot_forward > 0:
			#global_translate(get_global_transform().basis.x.normalized() * release_speed * delta)
		# because of the fast release speed, plunger will significantly overshoot past start position
		# to correct this, reset position if there is no plunger input and plunger is not behind start pos
		#else:
			#global_transform.origin = start_pos
			#is_at_start = true
		set_translation(start_pos.linear_interpolate(max_pos, move_progress))
