class_name DamageableState
extends "res://Scripts/State.gd"

signal is_active_changed(value)
signal health_changed(new_health, MAX_HEALTH)
signal death

const _MONEY_TEXT_3D_SCENE = preload("res://Scenes/MoneyText3D.tscn")

export var MAX_HEALTH = 3.0
export var BOMB_EXPLOSION_DAMAGE = 3.0
export var MISSILE_EXPLOSION_DAMAGE = 2.0
export var USE_SPEED_BASED_IMPACT_DAMAGE = false
export var FLAT_IMPACT_DAMAGE = 1.0
export var IMPACT_SPEED_DAMAGE_CONVERSION_RATE = 1.0
export var MIN_IMPACT_SPEED_FOR_DAMAGE = 5.0
export var MAX_IMPACT_DAMAGE = 15.0
export var MOENY_YIELD_IS_DAMAGE_BASED = true
export var FLAT_MONEY_YIELD = 10.0
export var DAMAGE_TO_MONEY_RATE = 1.0
export var MONEY_TEXT_HEIGHT = .5

var _health = 0


func _enter(var info = {}):
	var old_health = _health
	_health = MAX_HEALTH
	_on_health_changed(old_health)
	emit_signal("health_changed", _health, MAX_HEALTH)


func _handle_input(var input, var info = {}):
	match input:
		_state_machine.DamageIn.HIT_BY_PROJECTILE:
			_take_damage(_calc_damage(info["projectile"].get_linear_velocity().length()))
			_on_hit_by_projectile(info["projectile"])
		_state_machine.DamageIn.HIT_BY_EXPLOSION:
			_take_damage(BOMB_EXPLOSION_DAMAGE)
			_on_hit_by_explosion()


func on_hit_by_projectile(projectile):
	_take_damage(_calc_damage(projectile.get_linear_velocity().length()))
	_on_hit_by_projectile(projectile)


func _calc_damage(impact_speed):
	var damage = 0.0
	if USE_SPEED_BASED_IMPACT_DAMAGE:
		if impact_speed > MIN_IMPACT_SPEED_FOR_DAMAGE:
			damage = min(MAX_IMPACT_DAMAGE, impact_speed * IMPACT_SPEED_DAMAGE_CONVERSION_RATE)
	else:
		damage = FLAT_IMPACT_DAMAGE
	return damage


func _take_damage(damage):
	GameState.on_player_did_anything_at_all()
	var money_yield = 0.0
	if MOENY_YIELD_IS_DAMAGE_BASED:
		money_yield = damage * DAMAGE_TO_MONEY_RATE
	else:
		money_yield = FLAT_MONEY_YIELD
	if money_yield != 0:
		GameState.add_player_money(money_yield)
		var money_text_3d_instance = _MONEY_TEXT_3D_SCENE.instance()
		money_text_3d_instance.set_money_amount(money_yield)
		add_child(money_text_3d_instance)
		money_text_3d_instance.translate(Vector3(0, MONEY_TEXT_HEIGHT, 0))
	_set_health(_health - damage)


func _set_health(new_health):
	var old_health = _health
	_health = new_health
	if _health <= 0:
		emit_signal("death")
		_on_death()
	else:
		_on_health_changed(old_health)
		emit_signal("health_changed", _health, MAX_HEALTH)


func _on_hit_by_projectile(_projectile):
	pass


func _on_hit_by_explosion():
	pass


func _on_is_active_changed():
	pass


func _on_health_changed(_old_health):
	pass


func _on_death():
	pass
