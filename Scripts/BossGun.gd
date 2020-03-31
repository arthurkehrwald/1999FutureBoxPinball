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

enum In {
	BOSS_SHOOT_COMMAND,
	BOSS_IDLE_COMMAND,
	SHOT_TIMER_TIMEOUT,
	STUN_TIMER_TIMEOUT,
	HIT_DIRECTLY,
	HIT_EXPLOSION}

var state = null

func _ready():
	if SHOOT_ON_READY:
		state = $ShootingState
		$ShootingState.enter()
	else:
		state = $IdleState
		$IdleState.enter()
	$ShootingState/ShotTimer.set_wait_time(SECONDS_BETWEEN_SHOTS)


func handle_input(input, opt_info = null):
	state.handle_input(input, opt_info)


func _on_HitboxArea_body_entered(body):
	handle_input(In.HIT_DIRECTLY, body.get_linear_velocity().length())
	emit_signal("was_hit_directly", body.get_linear_velocity().length())	
	print("BossGun: was hit directly.")


func _on_impact(body):
	handle_input(In.HIT_DIRECTLY, body)


func _on_Bomb_explosion_hit():
	handle_input(In.HIT_EXPLOSION)
	emit_signal("was_hit_bomb_explosion")


func on_Explosion_hit():
	handle_input(In.HIT_EXPLOSION)
	emit_signal("was_hit_bomb_explosion")


func set_shooting(is_shooting):
	handle_input(In.BOSS_SHOOT_COMMAND if is_shooting else In.BOSS_IDLE_COMMAND)


func set_shot_rate_multiplier(multiplier):
	$ShootingState/ShotTimer.set_wait_time(SECONDS_BETWEEN_SHOTS * multiplier)


func _shoot():
	pass
