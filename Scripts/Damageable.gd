extends StaticBody

signal came_to_life
signal health_changed(new_health)
signal death

export var max_health = 3.0
export var bomb_explosion_damage = 3.0
export var static_impact_damage = 1.0
export var use_speed_based_impact_damage = false
export var impact_speed_damage_conversion_rate = 1.0
export var min_impact_speed_for_damage = 5.0
export var max_impact_damage = 15.0

var current_health = 3
var is_alive = false

func _on_HitboxArea_body_entered(body):
	if use_speed_based_impact_damage:
			if body.get_linear_velocity().length() > min_impact_speed_for_damage:
				current_health -= min(max_impact_damage, body.get_linear_velocity().length() * impact_speed_damage_conversion_rate)
	else:
		print(current_health)
		current_health -= static_impact_damage
	emit_signal("health_changed", current_health)
	if current_health <= 0:
		set_alive(false)

func _on_Bomb_explosion_hit():
	current_health -= bomb_explosion_damage
	emit_signal("health_changed", current_health)
	if current_health <= 0:
		set_alive(false)

func set_alive(_is_alive):
	is_alive = _is_alive
	if _is_alive:
		current_health = max_health
		emit_signal("came_to_life")
	else:
		current_health = 0
		emit_signal("death")
	emit_signal("health_changed", current_health)

func set_health(new_health):
	if is_alive:
		current_health = new_health
		if current_health <= 0:
			set_alive(false)
		else:
			emit_signal("health_changed", current_health)
	
