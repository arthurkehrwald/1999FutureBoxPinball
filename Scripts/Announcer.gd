extends Node

var current_line_is_important = false

onready var audio_player = AudioStreamPlayer.new()

func _ready():
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
