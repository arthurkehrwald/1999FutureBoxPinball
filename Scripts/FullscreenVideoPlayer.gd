class_name FullscreenVideoPlayer
extends VideoPlayer

class PlaybackManager extends Node:
	signal started(playback_manager)
	signal finished(playback_manager)
	
	var video_player = null
	var delay = 0
	var delay_timer = null
	var is_playing := false
	
	func _init(_video_player : VideoPlayer,_delay : float = 0.0):
		video_player = _video_player
		video_player.connect("finished", self, "_on_finished_clip")
		delay = _delay
		if delay > 0:
			delay_timer = Timer.new()
			delay_timer.wait_time = delay
			delay_timer.one_shot = true
			add_child(delay_timer)
			delay_timer.connect("timeout", self, "on_DelayTimer_timeout")

	
	func on_DelayTimer_timeout():
		play()
	
	
	func request_play():
		if delay > 0:
			delay_timer.start()
		else:
			play()
	
	
	func request_stop():
		if delay_timer:
			delay_timer.stop()
		on_stop_requested()
	
	
	func _play_stream(video_stream : VideoStream):		
		video_player.stream = video_stream
		video_player.play()
	
	
	func _on_finished_clip():
		pass
	
	func _on_finished_playback():
		is_playing = false
		emit_signal("finished", self)
	
	func play():
		is_playing = true
		emit_signal("started", self)
	
	
	func on_stop_requested():
		pass


class SingleVideoManager extends PlaybackManager:
	var video_stream = null
	
	func _init(_video_player : VideoPlayer,
			_video_stream : VideoStream,
			_delay : float = 0.0
			).(_video_player, _delay):
		video_stream = _video_stream
	
	
	func play():
		.play()
		_play_stream(video_stream)
	
	
	func on_stop_requested():
		.on_stop_requested()
		if video_player.stream != video_stream:
			return
		video_player.stop()
		video_player.stream = null
		_on_finished_playback()
	
	
	func _on_finished_clip():
		request_stop()


class LoopManager extends PlaybackManager:
	enum PlaybackState {IDLE, INTRO, LOOP, OUTRO }
	
	var playback_state = PlaybackState.IDLE setget _set_playback_state
	var intro = null
	var loop = null
	var outro = null
	
	func _init(_video_player : VideoPlayer,
			_intro : VideoStream,
			_loop : VideoStream,
			_outro : VideoStream,
			_delay : float = 0.0
			).(_video_player, _delay):
		intro = _intro
		loop = _loop
		outro = _outro
	
	
	func play():
		.play()
		_set_playback_state(PlaybackState.INTRO)
	
	
	func on_stop_requested():
		.on_stop_requested()
		_set_playback_state(PlaybackState.OUTRO)
	
	
	func _set_playback_state(value):
		if value == playback_state:
			return
		playback_state = value
		match playback_state:
			PlaybackState.IDLE:
				if video_player.stream == intro || video_player.stream == loop || video_player.stream == outro:
					video_player.stream = null
					video_player.request_stop()
			PlaybackState.INTRO:
				_play_stream(intro)
			PlaybackState.LOOP:
				_play_stream(loop)
			PlaybackState.OUTRO:
				_play_stream(outro)

	
	func _on_finished_clip():
		match playback_state:
			PlaybackState.IDLE:
				return
			PlaybackState.INTRO:
				if video_player.stream != intro:
					return
				_set_playback_state(PlaybackState.LOOP)
			PlaybackState.LOOP:
				if video_player.stream != loop:
					return
				video_player.play()
			PlaybackState.OUTRO:
				if video_player.stream != outro:
					return
				_on_finished_playback()

signal playback_finished

var active_playback_manager: PlaybackManager = null setget _set_active_playback_manager
var queued_playback_manager: PlaybackManager = null

export var pregrame_intro_stream: VideoStream = null
export var pregrame_loop_stream: VideoStream = null
export var pregrame_outro_stream: VideoStream = null
export var game_over_stream: VideoStream = null

onready var pregame_playback_manager = LoopManager.new(
	self,
	pregrame_intro_stream,
	pregrame_loop_stream,
	pregrame_outro_stream
)

onready var game_over_playback_manager = SingleVideoManager.new(
	self,
	game_over_stream,
	2.0
)

func _ready():
	add_child(pregame_playback_manager)
	add_child(game_over_playback_manager)


func play_pregame_video():
	_set_active_playback_manager(pregame_playback_manager)


func play_game_over_video():
	_set_active_playback_manager(game_over_playback_manager)


func _set_active_playback_manager(value: PlaybackManager):
	assert(value is PlaybackManager || value == null)
	if active_playback_manager == value:
		return
	if active_playback_manager and active_playback_manager.is_playing:
		active_playback_manager.request_stop()
		if value:
			queued_playback_manager = value
	else:
		active_playback_manager = value
		if active_playback_manager:
			active_playback_manager.connect("started", self, "on_PlaybackManager_started", [], CONNECT_ONESHOT)
			active_playback_manager.connect("finished", self, "on_PlaybackManager_finished", [], CONNECT_ONESHOT)
			active_playback_manager.request_play()
		else:
			visible = false
			get_tree().paused = false


func on_PlaybackManager_started(playback_manager):
	if playback_manager != active_playback_manager:
		return
	visible = true
	get_tree().paused = true


func on_PlaybackManager_finished(playback_manager):
	if playback_manager != active_playback_manager:
		return
	if queued_playback_manager:
		_set_active_playback_manager(queued_playback_manager)
	else:
		_set_active_playback_manager(null)
	emit_signal("playback_finished")

func _input(event):
	if event.is_action_pressed("start"):
		if active_playback_manager == pregame_playback_manager:
			active_playback_manager.request_stop()
