extends Spatial

var money_text_3d_scene = preload("res://Scenes/MoneyText3D.tscn")

signal came_to_life
signal health_changed(new_health, max_health)
signal death

export var max_health = 3.0
export var bomb_explosion_damage = 3.0
export var missile_explosion_damage = 2.0
export var static_impact_damage = 1.0
export var use_speed_based_impact_damage = false
export var impact_speed_damage_conversion_rate = 1.0
export var min_impact_speed_for_damage = 5.0
export var max_impact_damage = 15.0
export var gives_money = true
export var money_yield_is_damage_based = true
export var flat_money_yield = 10.0
export var damage_to_money_rate = 1.0

var current_health = 3
var is_alive = false

func _on_HitboxArea_body_entered(body):
	if is_alive:
		var damage = calc_damage(body.get_linear_velocity().length())
		if damage > 0:		
			take_damage(damage)

func _on_Bomb_explosion_hit():
	take_damage(bomb_explosion_damage)

func _on_Missile_explosion_hit():
	take_damage(missile_explosion_damage)
	
func set_alive(_is_alive):
	#print("Damageable (", name, "): alive - ", _is_alive)
	is_alive = _is_alive
	if _is_alive:
		current_health = max_health
		emit_signal("came_to_life")
	else:
		current_health = 0
		emit_signal("death")
	emit_signal("health_changed", current_health, max_health)
	
func calc_damage(impact_speed):
	var damage = 0.0
	if use_speed_based_impact_damage:
			if impact_speed > min_impact_speed_for_damage:
				damage = min(max_impact_damage, impact_speed * impact_speed_damage_conversion_rate)
	else:
		damage = static_impact_damage
	return damage

func take_damage(damage):
	if gives_money:	
			var money_yield = 0.0
			if money_yield_is_damage_based:
				money_yield = damage * damage_to_money_rate
			else:
				money_yield = flat_money_yield
			if money_yield != 0:
				GameState.set_player_money(GameState.player_money + money_yield)
				var money_text_3d_instance = money_text_3d_scene.instance()
				money_text_3d_instance.set_money_amount(money_yield)
				$MoneyTextPos.add_child(money_text_3d_instance)
				
	set_health(current_health - damage)

func set_health(new_health):
	current_health = new_health
	if current_health <= 0:
		set_alive(false)
	elif current_health >= max_health:
		set_alive(true)
	else:
		emit_signal("health_changed", current_health, max_health)
	
