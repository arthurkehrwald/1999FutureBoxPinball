extends StaticBody

export var shoot_on_ready = true
export var fire_rate = 3

export var impact_velocity_stun_duration_conversion_rate = .25
export var min_impact_velocity_for_stun = 5.0
export var max_impact_stun_duration = 5.0

export var bomb_explosion_stun_duration = 10.0

var stunned = false

func _ready():
	$ShotTimer.wait_time = fire_rate
	if shoot_on_ready:
		$ShotTimer.start()

func _on_HitboxArea_body_entered(body):
	#HitboxArea only scans for impacts and bombs - no layer check necessary
	if !get_collision_exceptions().has(body):
		if body.get_linear_velocity().length() > min_impact_velocity_for_stun:
			var stun_duration = min(max_impact_stun_duration, body.get_linear_velocity().length() * impact_velocity_stun_duration_conversion_rate)
			set_stunned(stun_duration)

func _on_Bomb_explosion_hit():
	set_stunned(bomb_explosion_stun_duration)
	
func set_stunned(stun_duration):
	if !stunned or $StunTimer.time_left < stun_duration:
		$StunTimer.stop()
		$StunTimer.wait_time = stun_duration
		$StunTimer.start()
		stunned = true
		print("gun stunned for %s"%stun_duration)
	
func _on_StunTimer_timeout():
	stunned = false
	print("gun no longer stunned")
