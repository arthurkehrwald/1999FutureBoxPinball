extends "res://Scripts/Damageable.gd"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _on_GameState_global_reset(_is_init):
	set_alive(true)
	
func _on_AnimationPlayer_animation_finished(_anim_name):
	print("Moon: recovered")
	set_alive(true)

func _on_Moon_came_to_life():
	print("moon alive")
	set_destroyed(false)

func _on_Moon_death():
	print("moon dead")
	set_destroyed(true)

func set_destroyed(destroyed):
	if destroyed:
		$AnimationPlayer.play("moon_animation")
	else:
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
	$HitboxArea.set_deferred("monitoring", !destroyed)
	$HitboxArea.set_deferred("monitorable", !destroyed)
	$MoonGate.set_deferred("monitoring", destroyed)
	$MoonGate.set_deferred("monitorable", destroyed)
	print("Moon: destroyed status - ", destroyed)
