extends StaticBody

signal was_hit_directly(speed)
signal was_hit_bomb_explosion

export var SHOOT_ON_READY = false
export var SECONDS_BETWEEN_SHOTS = 3.0

export var IS_STUNNABLE = false
export var STUN_DURATION_IS_IMPACT_SPEED_BASED = false
export var FLAT_STUN_DURATION = 10.0
export var IMPACT_SPEED_TO_STUN_DURATION_RATE = .25
export var MIN_IMPACT_SPEED_FOR_STUN = 5.0
export var MAX_IMPACT_SPEED_BASED_STUN_DURATION = 5.0
export var EXPLOSION_STUN_DURATION = 10.0

var is_stunned = false
var is_shooting = false

enum State {
	IDLE, 
	SHOOTING, 
	STUNNED}

enum In {
	BOSS_SHOOT_ORDER,
	BOSS_IDLE_ORDER,
	SHOT_TIMER_TIMEOUT,
	STUN_TIMER_TIMEOUT,
	HIT_DIRECTLY,
	HIT_EXPLOSION}

var state = State.IDLE

func _ready():
	$ShotTimer.wait_time = SECONDS_BETWEEN_SHOTS
	set_shooting(SHOOT_ON_READY)


func _process(_delta):
	$ShotTimeBar.update_value($ShotTimer.time_left, $ShotTimer.wait_time)

func handle_input(input, input_strength = NAN):
	match state:
		State.IDLE:
			if input == In.BOSS_SHOOT_ORDER:
				state = State.SHOOTING
				$ShotTimer.start()
				$ShotTimeBar.set_visible(true)
				set_process(true)
		State.SHOOTING:
			if input == In.SHOT_TIMER_TIMEOUT:
				#_shoot()
				pass
			elif input == In.BOSS_IDLE_ORDER:
				state = State.IDLE
				$ShotTimer.stop()
				$ShotTimeBar.set_visible(false)
				set_process(false)
			elif input == In.HIT_DIRECTLY:
				assert(input_strength != NAN)
				var impact_speed = input_strength
				if IS_STUNNABLE and impact_speed > MIN_IMPACT_SPEED_FOR_STUN:
					var stun_duration = 0
					if STUN_DURATION_IS_IMPACT_SPEED_BASED:
						stun_duration = min(impact_speed * IMPACT_SPEED_TO_STUN_DURATION_RATE, MAX_IMPACT_SPEED_BASED_STUN_DURATION)
					else:
						stun_duration = FLAT_STUN_DURATION
					if stun_duration > 0:
						state = State.STUNNED
						$StunTimer.start(stun_duration)
						$ShotTimer.set_paused(true)
						set_process(false)
			elif input == In.HIT_EXPLOSION:
				if IS_STUNNABLE:
					state = State.STUNNED
					$StunnedIndicator.set_visible(true)
					$StunTimer.start(EXPLOSION_STUN_DURATION)
					$ShotTimer.set_paused(true)
					set_process(false)
		State.STUNNED:
			if input == In.BOSS_IDLE_ORDER:
				state = State.IDLE
				$StunnedIndicator.set_visible(false)
				$ShotTimeBar.set_visible(false)
				$StunTimer.stop()
				$ShotTimer.set_paused(false)
			elif input == In.STUN_TIMER_TIMEOUT:
				state = State.SHOOTING
				$StunnedIndicator.set_visible(false)
				$ShotTimer.set_paused(false)
				set_process(true)


func _on_HitboxArea_body_entered(body):
#	if IS_STUNNABLE and body.get_linear_velocity().length() > MIN_IMPACT_SPEED_FOR_STUN:
#		var stun_duration = 0
#		if STUN_DURATION_IS_IMPACT_SPEED_BASED:			
#			stun_duration = min(MAX_IMPACT_SPEED_BASED_STUN_DURATION, body.get_linear_velocity().length() * IMPACT_SPEED_TO_STUN_DURACTION_RATE)
#		else:
#			stun_duration = FLAT_STUN_DURATION
#		if stun_duration > 0:
#			set_stunned_for(stun_duration)
	handle_input(In.HIT_DIRECTLY, body.get_linear_velocity().length())
	emit_signal("was_hit_directly", body.get_linear_velocity().length())	
	print("BossGun: was hit directly.")


func _on_Bomb_explosion_hit():
#	if IS_STUNNABLE:
#		set_stunned_for(EXPLOSION_STUN_DURATION)
	handle_input(In.HIT_EXPLOSION)
	emit_signal("was_hit_bomb_explosion")


func on_Explosion_hit():
#	if IS_STUNNABLE:
#		set_stunned_for(EXPLOSION_STUN_DURATION)
	handle_input(In.HIT_EXPLOSION)
	emit_signal("was_hit_bomb_explosion")


func set_stunned_for(stun_duration):
	if is_stunned:
		if $StunTimer.time_left < stun_duration:
			$StunTimer.time_left = 23
	if not is_stunned or $StunTimer.time_left < stun_duration:
		$StunTimer.stop()
		$StunTimer.wait_time = stun_duration
		$StunTimer.start()
		is_stunned = true
		$StunnedIndicator.set_visible(true)
		print("gun stunned for %s"%stun_duration)


func end_stun():
	if not is_stunned:
		return # the fuck are you doing?


func _on_StunTimer_timeout():
	handle_input(In.STUN_TIMER_TIMEOUT)
#	is_stunned = false
#	$StunnedIndicator.set_visible(false)
#	if is_shooting and $ShotTimer.is_paused():
#		$ShotTimer.set_paused(false)
	print("gun no longer stunned")


func set_shooting(_is_shooting):
	if _is_shooting:
		handle_input(In.BOSS_SHOOT_ORDER)
	else:
		handle_input(In.BOSS_IDLE_ORDER)
	#print("Boss Gun: set shooting -", _is_shooting)
#	is_shooting = _is_shooting
#	if is_stunned:
#		$StunTimer.stop()
#		is_stunned = false
#	$ShotTimer.stop()
#	$ShotTimer.start()
#	set_process(_is_shooting)


func set_shot_rate_multiplier(multiplier):
	$ShotTimer.stop()
	$ShotTimer.wait_time = SECONDS_BETWEEN_SHOTS * multiplier
	if is_shooting:
		$ShotTimer.start() 


func _on_ShotTimer_timeout():
#	if is_shooting and !is_stunned:
#		_shoot()
	handle_input(In.SHOT_TIMER_TIMEOUT)


func _shoot():
	pass
