extends VideoPlayer

class PlaybackManager extends Node:
	signal started(playback_manager)
	signal finished(playback_manager)
	
	var video_player = null
	var delay = 0
	var delay_timer = null
	
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
	
	
	func play():
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
		emit_signal("finished", self)
	
	
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
				emit_signal("finished", self)


var current_playback_manager

onready var playback_managers = {
	GameState.TESTING_STATE: null,
	GameState.PREGAME_STATE: LoopManager.new(
		self,
		preload("res://HUD/Videos/pregame_overlay_v2_intro.ogv"),
		preload("res://HUD/Videos/pregame_overlay_v2_loop.ogv"),
		preload("res://HUD/Videos/pregame_overlay_v2_outro.ogv")
	),
	GameState.EXPOSITION_STATE: null,
	GameState.ENEMY_FLEET_STATE: null,
	GameState.BOSS_APPEARS_STATE: null,
	GameState.MISSILES_STATE: null,
	GameState.TREX_STATE: null,
	GameState.BLACK_HOLE_STATE: null,
	GameState.ECLIPSE_STATE: null,
	GameState.VICTORY_STATE: SingleVideoManager.new(
		self,
		preload("res://HUD/Videos/victory_overlay.ogv"),
		5.0
	),
	GameState.DEFEAT_STATE: SingleVideoManager.new(
		self,
		preload("res://HUD/Videos/game_over_overlay_v2.ogv"),
		2.0
	)
}


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	for playback_manager in playback_managers.values():
		if playback_manager:
			add_child(playback_manager)


func on_GameState_changed(new_state, is_debug_skip):
	if not is_debug_skip and playback_managers[new_state] != null:
		if current_playback_manager:
			current_playback_manager.request_stop()
		current_playback_manager = playback_managers[new_state]
		current_playback_manager.connect("started", self, "on_PlaybackManager_started", [], CONNECT_ONESHOT)
		current_playback_manager.connect("finished", self, "on_PlaybackManager_finished", [], CONNECT_ONESHOT)
		current_playback_manager.request_play()
		if new_state is GameState.PostGameState:
			current_playback_manager.connect("finished", self, "on_PlaybackManager_finished_post_game_video", [], CONNECT_ONESHOT)
		elif new_state is GameState.PregameState:
			current_playback_manager.connect("finished", self, "on_PlaybackManager_finished_pre_game_video", [], CONNECT_ONESHOT)
	else:
		if current_playback_manager:
			visible = false
			get_tree().paused = false
			current_playback_manager = null


func on_PlaybackManager_started(playback_manager):
	if playback_manager != current_playback_manager:
		return
	visible = true
	get_tree().paused = true


func on_PlaybackManager_finished(playback_manager):
	if playback_manager != current_playback_manager:
		return
	visible = false
	get_tree().paused = false


func _input(event):
	if event.is_action_pressed("start"):
		if GameState.current_state is GameState.PregameState and current_playback_manager:
			current_playback_manager.request_stop()


func on_PlaybackManager_finished_pre_game_video(playback_manager):
	if playback_manager != current_playback_manager:
		return
	GameState.handle_event(GameState.Event.PREGAME_FINISHED)


func on_PlaybackManager_finished_post_game_video(playback_manager):
	if playback_manager != current_playback_manager:
		return
	GameState.handle_event(GameState.Event.POSTGAME_FINISHED)
