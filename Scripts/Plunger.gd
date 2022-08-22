extends KinematicBody

export var windup_speed = 3.0
export var release_speed = 10.0
export var max_distance = 5.0

var start_pos = Vector3()
var max_pos = Vector3()
var start_transform 
var max_transform
var move_progress = 0.0
var is_at_start = true
var is_active := true setget set_is_active

onready var pull_audio_player = get_node("PullAudioPlayer")
onready var release_audio_player = get_node("ReleaseAudioPlayer")

func set_is_active(value: bool):
	if value == is_active:
		return
	is_active = value


func _ready():
	add_to_group("plungers")
	start_pos = get_translation()
	max_pos = start_pos + get_transform().basis.z.normalized() * max_distance
	start_transform = Transform(Basis.IDENTITY, start_pos)
	max_transform = Transform(Basis.IDENTITY, max_pos)


func _input(event):
	if is_active and event.is_action_pressed("plunger"):
		pull_audio_player.play()
	elif is_active and event.is_action_released("plunger"):
		release_audio_player.play()
		pull_audio_player.stop()


func _physics_process(delta):
	if is_active and Input.is_action_pressed("plunger"):
		if move_progress < 1:
			move_progress += windup_speed / Engine.time_scale / max_distance * delta
			pull_audio_player.pitch_scale = move_progress + .5
	elif move_progress > 0:
		move_progress -= release_speed / Engine.time_scale / max_distance * delta
		if move_progress < 0:
			move_progress = 0
	
	set_transform(start_transform.interpolate_with(max_transform, move_progress))
