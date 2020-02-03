extends StaticBody

signal was_hit_directly(speed)
signal was_hit_bomb_explosion()

export var shoot_on_ready = false
export var base_firing_rate = 3

export var impact_velocity_stun_duration_conversion_rate = .25
export var min_impact_velocity_for_stun = 5.0
export var max_impact_stun_duration = 5.0

export var bomb_explosion_stun_duration = 10.0

var stunned = false
var is_firing = false

func _ready():
	$ShotTimer.wait_time = base_firing_rate
	if shoot_on_ready:
		is_firing = true
		$ShotTimer.start()

func _on_HitboxArea_body_entered(body):
	if body.get_linear_velocity().length() > min_impact_velocity_for_stun:
		var stun_duration = min(max_impact_stun_duration, body.get_linear_velocity().length() * impact_velocity_stun_duration_conversion_rate)
		set_stunned(stun_duration)
	emit_signal("was_hit_directly", body.get_linear_velocity().length())	

func _on_Bomb_explosion_hit():
	set_stunned(bomb_explosion_stun_duration)
	emit_signal("was_hit_bomb_explosion")
	
func on_Explosion_hit():
	set_stunned(bomb_explosion_stun_duration)
	emit_signal("was_hit_bomb_explosion")
	
func set_stunned(stun_duration):
	if !stunned or $StunTimer.time_left < stun_duration:
		$StunTimer.stop()
		$StunTimer.wait_time = stun_duration
		$StunTimer.start()
		stunned = true
		$Sprite3D.set_visible(false)
		print("gun stunned for %s"%stun_duration)
	
func _on_StunTimer_timeout():
	stunned = false
	$Sprite3D.set_visible(true)
	print("gun no longer stunned")

func set_firing(_is_firing):
	is_firing = _is_firing
	$ShotTimer.stop()
	$ShotTimer.start()
	
func set_firing_rate_multiplier(multiplier):
	$ShotTimer.stop()
	$ShotTimer.wait_time = base_firing_rate * multiplier
	if is_firing:
		$ShotTimer.start() 
