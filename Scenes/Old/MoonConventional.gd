extends Spatial

export var flight_duration = 5.0

func _ready():	
	$AnimationPlayer.playback_speed = 1.0 / flight_duration
	
func _on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		set_flying(false)

func set_flying(_is_flying):
	if _is_flying:
		$AnimationPlayer.play("moon_fly")
	else:
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()

func _on_MoonGate_came_to_life():
	set_flying(false)

func _on_MoonGate_death():
	set_flying(true)


