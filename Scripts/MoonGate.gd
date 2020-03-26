extends "res://Scripts/Damageable.gd"

export var spin_speed_multiplier = 1.0
export var spin_speed_falloff = 1.4
export var impulse_strength = 3.0

var current_spin_speed = 0.0

var spin_axis = Vector3(1, 0, 0)
var is_flying = false
var is_spinning = false


func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")


func _ready():
	set_process(false)


func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		set_process(false)
		is_spinning = false
		if $AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
		set_active(true)
		
	if new_stage == GameState.stage.BOSS_BEGIN or new_stage == GameState.stage.SOLAR_ECLIPSE:
			set_active(true)
	else:
			set_active(false)


func _on_is_active_changed():
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	if is_active:
		if not is_spinning:
			if is_flying:
				$AnimationPlayer.play_backwards("moon_spectral_transition")
			else:
				set_visible(false)	
		is_flying = false	
	else:
		Announcer.say("moon_destroyed")
		set_visible(true)
		set_deferred("is_flying", true)


func _on_MoonGateHitboxArea_body_entered(body):
	#print("MoonGate: hit")
	if !is_flying:
		Announcer.say("moon_dmg")
		
	var body_to_moon = get_global_transform().origin - body.get_global_transform().origin
	spin_axis = body.get_linear_velocity().cross(body_to_moon).normalized()
	var impact_speed = body.get_linear_velocity().length()
	current_spin_speed = impact_speed * spin_speed_multiplier
	set_process(true)
	
	if is_flying:
		var angle = body.get_linear_velocity().normalized().angle_to(-Vector3(0, 0, 1))
		#print("MoonGate: ball entered at angle - ", angle)
		if angle < PI / 2:
			body.apply_central_impulse(body.get_linear_velocity().normalized() * impulse_strength)
	elif not is_spinning:
		is_spinning = true
		set_visible(true)
		$AnimationPlayer.play("moon_spectral_transition")


func _process(delta):
	current_spin_speed -= spin_speed_falloff * delta
	if current_spin_speed > 0:
		$MeshInstance.set_transform($MeshInstance.get_transform().rotated(spin_axis, current_spin_speed * delta))
	else:
		#print("spin speed 0")
		is_spinning = false
		if not is_flying:
			$AnimationPlayer.play_backwards("moon_spectral_transition")
		set_process(false)


#called when moon is done flying
func _on_MoonAnimationPlayer_flying_animation_finished(_anim_name):
	set_active(true)


#called when moongate is done scaling
func _on_AnimationPlayer_scaling_animation_finished(_anim_name):
	if is_spinning:
		#print("MoonGate: done scaling up")
		set_visible(true)
	else:
		#print("MoonGate: done scaling down")
		if not is_flying:
			set_visible(false)
