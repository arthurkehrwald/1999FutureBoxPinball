extends Node

var player
var no_interrupt

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	
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
	
func _on_GameState_stage_changed(new_stage, _is_debug_skip):
	match new_stage:
		GameState.stage.EXPOSITION:
			say("begin", true)
		GameState.stage.ENEMY_FLEET:
			say("stage1", true)
		GameState.stage.BOSS_BEGIN:
			say("stage2", true)
		GameState.stage.SOLAR_ECLIPSE:
			say("solar_eclipse", true)
			
