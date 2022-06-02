extends AudioStreamPlayer

enum State { OFF, FADING_IN, ON, FADING_OUT }

export var TRACK_INDEX = 0
export var FADE_DUR_SECS = 3.0

var state = State.OFF setget set_state, get_state

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
	if val == State.FADING_OUT and state == State.OFF:
		return
	if val == State.FADING_IN and state == State.ON:
		return
	state = val
	if val == State.OFF or val == State.FADING_IN:
		volume_db = MIN_VOL_DB
	if val == State.ON or val == State.FADING_OUT:
		volume_db = MAX_VOL_DB
	if val == State.OFF:
		stop()
	else:
		if not playing:
			play()


func get_state() -> State:
	return state

func _process(delta):
	match state:
		State.FADING_IN:
			if volume_db >= MAX_VOL_DB:
				set_state(State.ON)
			else:
				volume_db += VOL_RANGE / FADE_DUR_SECS * delta
		State.FADING_OUT:
			if volume_db <= MIN_VOL_DB:
				set_state(State.OFF)
			else:
				volume_db -= VOL_RANGE / FADE_DUR_SECS * delta

func stop_playing():
	if state == State.ON or state == State.FADING_IN:
		set_state(State.FADING_OUT)

func start_playing():
	if state == State.OFF or state == State.FADING_OUT:
		set_state(State.FADING_IN)
