class_name BossGunStunned
extends "res://Scripts/State.gd"
# Interrupts shooting and dispays the stunned indicator when the boss gun gets
# stunned.

onready var _boss_gun = get_node("..")
onready var _timer = get_node("../Timer")
onready var _stunned_sprite = get_node("../StunnedSprite")

func _enter(var info = {}):
	assert(info != {})
	_timer.start(info["stun_duration"])
	_stunned_sprite.set_visible(true)


func _handle_input(var input, var info = {}):
	match input:
		_boss_gun.In.BOSS_IDLE_COMMAND:
			_boss_gun.transition_to("IdleState")
		_boss_gun.In.BOSS_SHOOT_COMMAND:
			_boss_gun.transition_to("ShootingState")
		_boss_gun.In.STUNNED:
			assert(info != {})
			if info["stun_duration"] > _timer.wait_time:
				_timer.start(info["stun_duration"])
		_boss_gun.In.TIMER_TIMEOUT:
			_boss_gun.transition_to("ShootingState")


func _exit():
	_timer.stop()
	_stunned_sprite.set_visible(false)
