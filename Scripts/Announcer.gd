extends Node

var player

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	
func _ready():
	set_pause_mode(Node.PAUSE_MODE_PROCESS)
	player = AudioStreamPlayer.new()
	self.add_child(player)

func say(what):
	if player != null:
		player.stream = load("res://Audio/Announcer/announcer_" + what + ".wav")
		player.play()
	
func _on_GameState_stage_changed(new_stage, _is_debug_skip):
	match new_stage:
		GameState.stage.EXPOSITION:
			say("begin")
		GameState.stage.ENEMY_FLEET:
			say("stage1")
		GameState.stage.BOSS_BEGIN:
			say("stage2")
		GameState.stage.SOLAR_ECLIPSE:
			say("solar_eclipse")
			
