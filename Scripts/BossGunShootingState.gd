extends Spatial

onready var boss_gun = get_node("..")
onready var idle_state = get_node("../IdleState")
onready var stunned_state = get_node("../StunnedState")

func enter():
	$ShotTimer.start()
	$ShotTimeBar.set_visible(true)
	set_process(true)

func handle_input(var input, var input_strength = NAN):
	match input:
		boss_gun.In.SHOT_TIMER_TIMEOUT:
			boss_gun._shoot()
		boss_gun.In.BOSS_IDLE_COMMAND:
			exit()
			idle_state.enter()
			boss_gun.state = idle_state
		boss_gun.In.HIT_DIRECTLY:
			assert(input_strength != NAN)
			if boss_gun.IS_STUNNABLE and input_strength > boss_gun.MIN_IMPACT_SPEED_FOR_STUN:
				exit()
				stunned_state.enter(stunned_state.ImpactType.DIRECT, input_strength)
				boss_gun.state = stunned_state
		boss_gun.In.HIT_EXPLOSION:
			if boss_gun.IS_STUNNABLE:
				exit()
				stunned_state.enter(stunned_state.ImpactType.EXPLOSION)
				boss_gun.state = stunned_state


func exit():
	$ShotTimer.stop()
	$ShotTimeBar.set_visible(false)
	set_process(false)


func _process(_delta):
	$ShotTimeBar.update_value($ShotTimer.time_left, $ShotTimer.wait_time)


func _on_ShotTimer_timeout():
	boss_gun.handle_input(boss_gun.In.SHOT_TIMER_TIMEOUT)
