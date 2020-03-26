extends StaticBody

signal was_hit_directly(speed)
signal was_hit_bomb_explosion

export var SHOOT_ON_READY = false
export var SECONDS_BETWEEN_SHOTS = 3.0

export var IS_STUNNABLE = false
export var STUN_DURATION_IS_IMPACT_SPEED_BASED = false
export var FLAT_STUN_DURATION = 10.0
export var IMPACT_SPEED_TO_STUN_DURACTION_RATE = .25
export var MIN_IMPACT_SPEED_FOR_STUN = 5.0
export var MAX_IMPACT_SPEED_BASED_STUN_DURATION = 5.0
export var EXPLOSION_STUN_DURATION = 10.0

var is_stunned = false
var is_shooting = false

func _ready():
	$ShotTimer.wait_time = SECONDS_BETWEEN_SHOTS
	set_shooting(SHOOT_ON_READY)
	
func _process(_delta):
	$RadialBar3D.update_value($ShotTimer.time_left, $ShotTimer.wait_time)

func _on_HitboxArea_body_entered(body):
	if IS_STUNNABLE and body.get_linear_velocity().length() > MIN_IMPACT_SPEED_FOR_STUN:
		var stun_duration = 0
		if STUN_DURATION_IS_IMPACT_SPEED_BASED:			
			stun_duration = min(MAX_IMPACT_SPEED_BASED_STUN_DURATION, body.get_linear_velocity().length() * IMPACT_SPEED_TO_STUN_DURACTION_RATE)
		else:
			stun_duration = FLAT_STUN_DURATION
		if stun_duration > 0:
			set_stunned(stun_duration)
	emit_signal("was_hit_directly", body.get_linear_velocity().length())	
	print("BossGun: was hit directly.")

func _on_Bomb_explosion_hit():
	if IS_STUNNABLE:
		set_stunned(EXPLOSION_STUN_DURATION)
	emit_signal("was_hit_bomb_explosion")
	
func on_Explosion_hit():
	if IS_STUNNABLE:
		set_stunned(EXPLOSION_STUN_DURATION)
	emit_signal("was_hit_bomb_explosion")
	
func set_stunned(stun_duration):
	if !is_stunned or $StunTimer.time_left < stun_duration:
		$StunTimer.stop()
		$StunTimer.wait_time = stun_duration
		$StunTimer.start()
		is_stunned = true
		$StunnedIndicator.set_visible(true)
		print("gun stunned for %s"%stun_duration)
	
func _on_StunTimer_timeout():
	is_stunned = false
	$StunnedIndicator.set_visible(false)
	print("gun no longer stunned")

func set_shooting(_is_shooting):
	#print("Boss Gun: set shooting -", _is_shooting)
	is_shooting = _is_shooting
	$ShotTimer.stop()
	$ShotTimer.start()
	set_process(_is_shooting)
	
func set_shot_rate_multiplier(multiplier):
	$ShotTimer.stop()
	$ShotTimer.wait_time = SECONDS_BETWEEN_SHOTS * multiplier
	if is_shooting:
		$ShotTimer.start() 

func _on_ShotTimer_timeout():
	if is_shooting and !is_stunned:
		_shoot()

func _shoot():
	pass
