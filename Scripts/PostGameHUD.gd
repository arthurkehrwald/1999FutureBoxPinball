extends Control

var was_restarted_already = false

func _enter_tree():
	#GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	GameState.connect("victory", self, "set_result", [true])
	GameState.connect("defeat", self, "set_result", [false])
	pass
	
func _ready():
	$TimeRemainingBar.max_value = 1000
	set_process(false)
	set_visible(false)
	
func set_result(has_player_won):
	get_tree().paused = true
	set_visible(true)
	set_process(true)
	if has_player_won:
		Announcer.say("victory")
		$ResultLabel.text = "Victory!"
	else:
		Announcer.say("sux")
		$ResultLabel.text = "Game Over!"
	$RestartTimer.start()
	
func _process(_delta):
	$TimeRemainingLabel.text = str(round($RestartTimer.time_left))
	$TimeRemainingBar.value = $RestartTimer.time_left * 100
	
#func _on_GameState_stage_changed(new_stage, is_debug_skip):
#	if is_debug_skip or new_stage == GameState.stage.PREGAME:
#		get_tree().paused = false
#		set_visible(false)
#		set_process(false)
#		was_restarted_already = true
#		$RestartTimer.stop()

func _on_RestartTimer_timeout():
	#print("PostGameHud: timer ran out")
	if !was_restarted_already:
		get_tree().paused = false
		set_visible(false)
		set_process(false)
		GameState.on_PostGameHUD_finished()
