extends Node

var current_line_is_important = false

onready var audio_player = AudioStreamPlayer.new()


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	audio_player.bus = "Voices"
	self.add_child(audio_player)


func say(what, this_is_important = false):
	if audio_player == null:
		return
	if not (audio_player.is_playing() and current_line_is_important) or this_is_important:
		current_line_is_important = this_is_important
		audio_player.stream = load("res://Audio/Announcer/announcer_" + what + ".wav")
		audio_player.play()


func on_GameState_changed(new_state, _is_debug_skip):
	match new_state:
		GameState.EXPOSITION_STATE:
			say("begin", true)
		GameState.ENEMY_FLEET_STATE:
			say("stage1", true)
		GameState.BOSS_APPEARS_STATE:
			say("stage2", true)
		GameState.ECLIPSE_STATE:
			say("solar_eclipse", true)
		GameState.VICTORY_STATE:
			say("victory", true)
		GameState.DEFEAT_STATE:
			say("sux", true)
