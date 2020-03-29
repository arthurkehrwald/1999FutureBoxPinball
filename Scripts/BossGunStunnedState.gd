extends Spatial

enum ImpactType {DIRECT, EXPLOSION}

onready var boss_gun = get_node("..")
onready var idle_state = get_node("../IdleState")
onready var shooting_state = get_node("../ShootingState")

func enter(var impact_type, var impact_speed = NAN):
	assert(not(impact_type == ImpactType.DIRECT and impact_speed == NAN))
	var stun_duration = 0
	match impact_type:
		ImpactType.DIRECT:
			assert(impact_speed != NAN)
			if boss_gun.STUN_DURATION_IS_IMPACT_SPEED_BASED:
				stun_duration = min(
					impact_speed * boss_gun.IMPACT_SPEED_TO_STUN_DURATION_RATE,
					boss_gun.MAX_IMPACT_SPEED_BASED_STUN_DURATION)
			else:
				stun_duration = boss_gun.FLAT_STUN_DURATION
		ImpactType.EXPLOSION:
			stun_duration = boss_gun.EXPLOSION_STUN_DURATION
	if stun_duration > $StunTimer.get_time_left():
		$StunTimer.start(stun_duration)
	$StunnedIndicator.set_visible(true)


func handle_input(var input, var input_strength = NAN):
	match input:
		boss_gun.In.BOSS_IDLE_COMMAND:
			exit()
			idle_state.enter()
			boss_gun.state = idle_state
		boss_gun.In.HIT_DIRECTLY:
			assert(input_strength != NAN)
			enter(ImpactType.DIRECT, input_strength)
		boss_gun.In.HIT_EXPLOSION:
			enter(ImpactType.EXPLOSION)
		boss_gun.In.STUN_TIMER_TIMEOUT:
			exit()
			shooting_state.enter()
			boss_gun.state = shooting_state


func exit():
	$StunTimer.stop()
	$StunnedIndicator.set_visible(false)


func _on_StunTimer_timeout():
	boss_gun.handle_input(boss_gun.In.STUN_TIMER_TIMEOUT)
