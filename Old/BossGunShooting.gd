class_name BossGunShooting
extends "res://Scripts/State.gd"

onready var _boss_gun = get_node("..")
onready var _timer = get_node("../Timer")
onready var _shot_time_bar = get_node("../ShotTimeBar3D/Viewport/Bar")


func _enter(var _info = {}):
	_timer.start(_boss_gun.SECONDS_BETWEEN_SHOTS)
	_shot_time_bar.set_visible(true)
	set_process(true)


func _handle_input(var input, var info = {}):
	match input:
		_boss_gun.In.TIMER_TIMEOUT:
			_boss_gun._shoot()
		_boss_gun.In.BOSS_IDLE_COMMAND:
			_boss_gun.transition_to("IdleState")
		_boss_gun.In.STUNNED:
			_boss_gun.transition_to("StunnedState", info)


func _exit():
	_timer.stop()
	_shot_time_bar.set_visible(false)
	set_process(false)


func _process(_delta):
	_shot_time_bar.update_value(_timer.time_left, 69, _timer.wait_time)
