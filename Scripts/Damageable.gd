extends Spatial

var money_text_3d_scene = preload("res://Scenes/MoneyText3D.tscn")

signal is_active_changed(_is_active)
signal health_changed(new_health, MAX_HEALTH)
signal death

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

var current_health = 0
var is_active = false


func _ready():
	$RayCast.set_global_transform(Transform(Basis.IDENTITY, get_global_transform().origin))


func _on_HitboxArea_body_entered(body):
	if is_active:
		var damage = calc_damage(body.get_linear_velocity().length())
		if damage > 0:		
			take_damage(damage)


func _on_Bomb_explosion_hit(explosion_pos):
	$RayCast.set_cast_to(explosion_pos - $RayCast.get_global_transform().origin)
	$RayCast.force_raycast_update()
	$RayCast.enabled = true
	if !$RayCast.is_colliding():
		take_damage(BOMB_EXPLOSION_DAMAGE)


func _on_Missile_explosion_hit(_explosion_pos):
	take_damage(MISSILE_EXPLOSION_DAMAGE)


func on_Explosion_hit(type, explosion_pos):
	$RayCast.set_cast_to(explosion_pos - $RayCast.get_global_transform().origin)
	$RayCast.force_raycast_update()
	$RayCast.enabled = true
	if $RayCast.is_colliding():
		print("Damageable: explosion blocked")
	else:
		match type:
			0:
				take_damage(BOMB_EXPLOSION_DAMAGE)
			1:
				take_damage(MISSILE_EXPLOSION_DAMAGE)


func set_active(_is_active):
	#print("Damageable (", name, "): alive - ", _is_active)
	is_active = _is_active
	var old_health = current_health
	if _is_active:
		current_health = MAX_HEALTH
	else:
		current_health = 0
	_on_is_active_changed()
	emit_signal("is_active_changed", _is_active)
	_on_health_changed(old_health)
	emit_signal("health_changed", current_health, MAX_HEALTH)


func calc_damage(impact_speed):
	var damage = 0.0
	if USE_SPEED_BASED_IMPACT_DAMAGE:
		if impact_speed > MIN_IMPACT_SPEED_FOR_DAMAGE:
			damage = min(MAX_IMPACT_DAMAGE, impact_speed * IMPACT_SPEED_DAMAGE_CONVERSION_RATE)
	else:
		damage = FLAT_IMPACT_DAMAGE
	return damage


func take_damage(damage):
	GameState.on_player_did_anything_at_all()
	var money_yield = 0.0
	if MOENY_YIELD_IS_DAMAGE_BASED:
		money_yield = damage * DAMAGE_TO_MONEY_RATE
	else:
		money_yield = FLAT_MONEY_YIELD
	if money_yield != 0:
		#GameState.set_player_money(GameState.player_money + money_yield)
		#print(name, " took ", damage, ", money yield - ", money_yield)
		GameState.add_player_money(money_yield)
		var money_text_3d_instance = money_text_3d_scene.instance()
		money_text_3d_instance.set_money_amount(money_yield)
		$MoneyTextPos.add_child(money_text_3d_instance)
	set_health(current_health - damage)


func set_health(new_health):
	var old_health = current_health
	current_health = new_health
	if current_health <= 0:
		emit_signal("death")
		_on_death()
		set_active(false)
	else:
		_on_health_changed(old_health)
		emit_signal("health_changed", current_health, MAX_HEALTH)


func _on_is_active_changed():
	pass


func _on_health_changed(_old_health):
	pass


func _on_death():
	pass
