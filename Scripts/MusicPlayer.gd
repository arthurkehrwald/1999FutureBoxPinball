extends Node

export var crossfade_duration = 5.0
export var fade_out_volume_lower_amount = 50

var fade_out_player
var fade_in_player
var fade_progress = 0
var target_volume

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	
func _ready():
	target_volume = $Track1.volume_db
	set_process(false)
	
func _process(delta):
	fade_progress += delta / crossfade_duration
	if fade_progress < 1.0:
		fade_in_player.volume_db = lerp(target_volume - fade_out_volume_lower_amount, target_volume, fade_progress)
		fade_out_player.volume_db = lerp(target_volume, target_volume - fade_out_volume_lower_amount, fade_progress)
	else:
		fade_out_player.stop()
		set_process(false)
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	match new_stage:
		GameState.stage.PREGAME:
			$Track1.play()
			$Track2.stop()
			$Track3.stop()
		GameState.stage.EXPOSITION:
			if is_debug_skip:
				$Track1.play()
				$Track2.stop()
				$Track3.stop()
		GameState.stage.ENEMY_FLEET:
			if is_debug_skip:
				$Track1.play()
				$Track2.stop()
				$Track3.stop()
		GameState.stage.BOSS_BEGIN:
			if is_debug_skip:
				$Track1.stop()
				$Track2.play()
				$Track3.stop()
			$Track1.volume_db = target_volume
			$Track2.volume_db = target_volume - fade_out_volume_lower_amount
			$Track2.play()
			fade_out_player = $Track1
			fade_in_player = $Track2
			fade_progress = 0
			set_process(true)
		GameState.stage.SOLAR_ECLIPSE:
			if is_debug_skip:
				$Track1.stop()
				$Track2.stop()
				$Track3.play()
			$Track2.volume_db = target_volume
			$Track3.volume_db = target_volume - fade_out_volume_lower_amount
			$Track3.play()
			fade_out_player = $Track2
			fade_in_player = $Track3
			fade_progress = 0
			set_process(true)
