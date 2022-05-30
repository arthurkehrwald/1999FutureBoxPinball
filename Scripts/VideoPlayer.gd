extends VideoPlayer

class PlaybackManager extends Object:
	signal finished(playback_manager)
	
	var video_player = null
	
	func _init(_video_player : VideoPlayer):
		video_player = _video_player
		video_player.connect("finished", self, "_on_finished_clip")
	
	
	func play():
		pass
	
	
	func stop():
		pass
	
	
	func _play_stream(video_stream : VideoStream):
		video_player.stream = video_stream
		video_player.play()
	
	
	func _on_finished_clip():
		pass


class SingleVideoManager extends PlaybackManager:
	var video_stream = null
	
	func _init(_video_player : VideoPlayer, _video_stream : VideoStream).(_video_player):
		video_stream = _video_stream
	
	
	func play():
		_play_stream(video_stream)
	
	
	func stop():
		if video_player.stream != video_stream:
			return
		video_player.stop()
		video_player.stream = null
		emit_signal("finished", self)
	
	func _on_finished_clip():
		stop()


class LoopManager extends PlaybackManager:
	enum PlaybackState {IDLE, INTRO, LOOP, OUTRO }
	
	var playback_state = PlaybackState.IDLE setget _set_playback_state
	var intro = null
	var loop = null
	var outro = null
	
	func _init(_video_player : VideoPlayer, _intro : VideoStream, _loop : VideoStream, _outro : VideoStream).(_video_player):
		intro = _intro
		loop = _loop
		outro = _outro
	
	
	func play():
		_set_playback_state(PlaybackState.INTRO)
	
	
	func stop():
		_set_playback_state(PlaybackState.OUTRO)
	
	
	func _set_playback_state(value):
		if value == playback_state:
			return
		playback_state = value
		match playback_state:
			PlaybackState.IDLE:
				if video_player.stream == intro || video_player.stream == loop || video_player.stream == outro:
					video_player.stream = null
					video_player.stop()
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

onready var video = {
	GameState.TESTING_STATE: null,
	GameState.PREGAME_STATE: LoopManager.new(
		self,
		preload("res://HUD/Videos/pregame_overlay_v2_intro.ogv"),
		preload("res://HUD/Videos/pregame_overlay_v2_loop.ogv"),
		preload("res://HUD/Videos/pregame_overlay_v2_outro.ogv")
	),
	GameState.EXPOSITION_STATE: null,
	GameState.ENEMY_FLEET_STATE: SingleVideoManager.new(
		self,
		preload("res://HUD/Videos/stage_one_overlay_v2.ogv")
	),
	GameState.BOSS_APPEARS_STATE: SingleVideoManager.new(
		self,
		preload("res://HUD/Videos/stage_two_overlay_v2.ogv")
	),
	GameState.MISSILES_STATE: null,
	GameState.TREX_STATE: null,
	GameState.BLACK_HOLE_STATE: null,
	GameState.ECLIPSE_STATE: null,
	GameState.VICTORY_STATE: SingleVideoManager.new(
		self,
		preload("res://HUD/Videos/victory_overlay.ogv")
	),
	GameState.DEFEAT_STATE: SingleVideoManager.new(
		self,
		preload("res://HUD/Videos/game_over_overlay_v2.ogv")
	)
}


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")


func on_GameState_changed(new_state, is_debug_skip):
	if not is_debug_skip and video[new_state] != null:
		if current_playback_manager:
			current_playback_manager.stop()
		current_playback_manager = video[new_state]
		current_playback_manager.play()
		current_playback_manager.connect("finished", self, "on_PlaybackManager_finished", [], CONNECT_ONESHOT)
		if new_state is GameState.PostGameState:
			current_playback_manager.connect("finished", self, "on_PlaybackManager_finished_post_game_video", [], CONNECT_ONESHOT)
		elif new_state is GameState.PregameState:
			current_playback_manager.connect("finished", self, "on_PlaybackManager_finished_pre_game_video", [], CONNECT_ONESHOT)
		visible = true
		get_tree().paused = true
	else:
		if current_playback_manager:
			visible = false
			get_tree().paused = false
			current_playback_manager = null


func on_PlaybackManager_finished(playback_manager):
	if playback_manager != current_playback_manager:
		return
	visible = false
	get_tree().paused = false


func _input(event):
	if event.is_action_pressed("start"):
		if GameState.current_state is GameState.PregameState and current_playback_manager:
			current_playback_manager.stop()


func on_PlaybackManager_finished_pre_game_video(playback_manager):
	if playback_manager != current_playback_manager:
		return
	GameState.handle_event(GameState.Event.PREGAME_FINISHED)


func on_PlaybackManager_finished_post_game_video(playback_manager):
	if playback_manager != current_playback_manager:
		return
	GameState.handle_event(GameState.Event.POSTGAME_FINISHED)
