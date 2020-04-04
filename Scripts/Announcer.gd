extends Node

var player
var no_interrupt

func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")


func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	player = AudioStreamPlayer.new()
	self.add_child(player)


func say(what, _no_interrupt = false):
	if player != null:
		if not (player.is_playing() and no_interrupt) or _no_interrupt:
			no_interrupt = _no_interrupt
			player.stream = load("res://Audio/Announcer/announcer_" + what + ".wav")
			player.play()


func _on_GameState_changed(new_state, _is_debug_skip):
	match new_state:
		GameState.EXPOSITION:
			say("begin", true)
		GameState.ENEMY_FLEET:
			say("stage1", true)
		GameState.BOSS_APPEARS:
			say("stage2", true)
		GameState.ECLIPSE:
			say("ECLIPSE", true)
