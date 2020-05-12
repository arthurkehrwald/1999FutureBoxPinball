extends KinematicBody

export var windup_speed = 3.0
export var release_speed = 10.0
export var max_distance = 5.0

var start_pos = Vector3()
var	max_pos = Vector3()
var start_transform 
var max_transform
var move_progress = 0.0
var is_at_start = true

onready var pull_audio_player = get_node("PullAudioPlayer")
onready var release_audio_player = get_node("ReleaseAudioPlayer")


func _ready():
	start_pos = get_translation()
	max_pos = start_pos + get_transform().basis.z.normalized() * max_distance
	start_transform = Transform(Basis.IDENTITY, start_pos)
	max_transform = Transform(Basis.IDENTITY, max_pos)


func _input(event):
	if event.is_action_pressed("ui_down"):
		pull_audio_player.play()
	elif event.is_action_released("ui_down"):
		release_audio_player.play()
		pull_audio_player.stop()


func _physics_process(delta):
	if Input.is_action_pressed("ui_down"):
		if move_progress < 1:
			move_progress += windup_speed / Engine.time_scale / max_distance * delta
			pull_audio_player.pitch_scale = move_progress + .5
	elif move_progress > 0:
		move_progress -= release_speed / Engine.time_scale / max_distance * delta
		if move_progress < 0:
			move_progress = 0
	
	#set_translation(start_pos.linear_interpolate(max_pos, move_progress))
	set_transform(start_transform.interpolate_with(max_transform, move_progress))
		
