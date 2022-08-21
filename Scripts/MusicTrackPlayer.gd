class_name MusicTrackPlayer
extends AudioStreamPlayer

enum Status { OFF, FADING_IN, ON, FADING_OUT }

export var TRACK_INDEX = 0
export var FADE_DUR_SECS = 3.0

var state = Status.OFF setget set_state, get_state

onready var MAX_VOL_DB = volume_db
onready var MIN_VOL_DB = volume_db - 50
onready var VOL_RANGE = abs(MAX_VOL_DB - MIN_VOL_DB)

func _enter_tree():
	GameState.connect("state_changed", self, "on_GameState_state_changed")

func on_GameState_state_changed(new_state, _is_debug_skip):
	match new_state.MUSIC_TRACK:
		-1:
			stop_playing()
		0:
			pass # Keep playing whatever track is currently on
		TRACK_INDEX:
			start_playing()
		_:
			stop_playing()


func set_state(val):
	if val == state:
		return
	if val == Status.FADING_OUT and state == Status.OFF:
		return
	if val == Status.FADING_IN and state == Status.ON:
		return
	state = val
	if val == Status.OFF or val == Status.FADING_IN:
		volume_db = MIN_VOL_DB
	if val == Status.ON or val == Status.FADING_OUT:
		volume_db = MAX_VOL_DB
	if val == Status.OFF:
		stop()
	else:
		if not playing:
			play()


func get_state():
	return state

func _process(delta):
	match state:
		Status.FADING_IN:
			if volume_db >= MAX_VOL_DB:
				set_state(Status.ON)
			else:
				volume_db += VOL_RANGE / FADE_DUR_SECS * delta
		Status.FADING_OUT:
			if volume_db <= MIN_VOL_DB:
				set_state(Status.OFF)
			else:
				volume_db -= VOL_RANGE / FADE_DUR_SECS * delta

func stop_playing():
	if state == Status.ON or state == Status.FADING_IN:
		set_state(Status.FADING_OUT)

func start_playing():
	if state == Status.OFF or state == Status.FADING_OUT:
		set_state(Status.FADING_IN)
