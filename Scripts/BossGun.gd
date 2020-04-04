class_name BossGun
extends "res://Scripts/StateMachine.gd"
# Translates incoming events into inputs its states can interpret.

signal was_hit_by_projectile(projectile)
signal was_hit_by_explosion

enum In {
	BOSS_SHOOT_COMMAND,
	BOSS_IDLE_COMMAND,
	TIMER_TIMEOUT,
	STUNNED}

export var SECONDS_BETWEEN_SHOTS = 3.0
export var IS_STUNNABLE = false
export var STUN_DURATION_IS_IMPACT_SPEED_BASED = false
export var FLAT_STUN_DURATION = 10.0
export var IMPACT_SPEED_TO_STUN_DURATION_RATE = .25
export var MIN_IMPACT_SPEED_FOR_STUN = 5.0
export var MAX_IMPACT_SPEED_BASED_STUN_DURATION = 5.0
export var EXPLOSION_STUN_DURATION = 10.0

onready var _timer = get_node("Timer")


func _ready():
	_state._enter()
	_timer.connect("timeout", self, "_on_Timer_timeout")


func start_shooting():
	_state._handle_input(In.BOSS_SHOOT_COMMAND)


func stop_shooting():
	_state.handle_input(In.BOSS_IDLE_COMMAND)


func _on_hit_by_projectile(projectile):
	emit_signal("was_hit_by_projectile", projectile)
	var impact_speed = projectile.get_linear_velocity().length
	if IS_STUNNABLE and impact_speed >= MIN_IMPACT_SPEED_FOR_STUN:
		var stun_duration = 0
		if STUN_DURATION_IS_IMPACT_SPEED_BASED:
			stun_duration = min(MAX_IMPACT_SPEED_BASED_STUN_DURATION,
					impact_speed * IMPACT_SPEED_TO_STUN_DURATION_RATE)
		else:
			stun_duration = FLAT_STUN_DURATION
		if stun_duration > 0:
			_state._handle_input(In.STUNNED, {"stun_duration": stun_duration})


func _on_hit_by_explosion():
	emit_signal("was_hit_by_explosion")
	if IS_STUNNABLE:
		_state._handle_input(In.STUNNED, {"stun_duration": EXPLOSION_STUN_DURATION})


func _on_Timer_timeout():
	_state._handle_input(In.TIMER_TIMEOUT)


func _shoot():
	pass
