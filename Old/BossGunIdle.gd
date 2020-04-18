class_name BossGunIdle
extends "res://Scripts/State.gd"

onready var _boss_gun = get_node("..")

func _handle_input(var input, var _opt_info = null):
	if input == _boss_gun.In.BOSS_SHOOT_COMMAND:
		_boss_gun.transition_to("ShootingState")
