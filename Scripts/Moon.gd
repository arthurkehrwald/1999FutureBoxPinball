extends "res://Scripts/Damageable.gd"

export var flight_duration = 50.0
export var spin_speed_multiplier = 1.0
export var spin_speed_falloff = 1.4

var current_spin_speed = 0.0

var spin_axis = Vector3(1, 0, 0)
var impact_speed = 0.0
var is_flying = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _ready():
	$AnimationPlayer.playback_speed = 1 / flight_duration
	set_process(false)
	
func _on_GameState_global_reset(is_init):
	if !is_init:
		set_process(false)
	set_alive(true)
	
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "moon_fly":
		print("Moon: recovered")
		set_alive(true)

func _on_Moon_came_to_life():
	print("moon alive")
	set_flying(false)

func _on_Moon_death():
	print("moon dead")
	set_flying(true)

func set_flying(_is_flying):
	if _is_flying:
		$AnimationPlayer.play("moon_fly")
	else:
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
	$HitboxArea.set_deferred("monitoring", !_is_flying)
	$HitboxArea.set_deferred("monitorable", !_is_flying)
	$MoonGatePivot/MoonGate.set_deferred("monitoring", _is_flying)
	$MoonGatePivot/MoonGate.set_deferred("monitorable", _is_flying)
	$MoonGatePivot/MoonGate.set_visible(_is_flying)
	$MeshInstance.set_visible(true)
	print("Moon: $MoonGatePivot/MoonGatePivot/MoonGate status - ", _is_flying)
	is_flying = _is_flying

func _on_MoonHitboxArea_body_entered(body):
	var body_to_moon = $MeshInstance.get_global_transform().origin - body.get_global_transform().origin
	spin_axis = body.get_linear_velocity().cross(body_to_moon).normalized()
	impact_speed = body.get_linear_velocity().length()
	current_spin_speed = impact_speed * spin_speed_multiplier
	prepare_spin()

func _process(delta):
	if !is_flying:
		current_spin_speed -= spin_speed_falloff * delta
	if current_spin_speed > 0:
		pass
		$MoonGatePivot/MoonGate/MeshInstance.set_transform($MoonGatePivot/MoonGate/MeshInstance.get_transform().rotated(spin_axis, current_spin_speed * delta))
	else:
		stop_spinning()

func prepare_spin():
	$MoonGatePivot/MoonGate/AnimationPlayer.play("moon_spectral_transition")
	$MeshInstance.set_visible(false)
	$MoonGatePivot/MoonGate.set_visible(true)	
	set_process(true)

func stop_spinning():
	$MoonGatePivot/MoonGate/AnimationPlayer.play_backwards("moon_spectral_transition")
	yield($MoonGatePivot/MoonGate/AnimationPlayer, "animation_finished")
	$MeshInstance.set_visible(true)
	$MoonGatePivot/MoonGate.set_visible(false)	
	set_process(false)
