class_name Projectile
extends RigidBody
# Notifies bodies and areas when its area hits them and calls virtual functions
# that derived classes can implement to respond to the collision. Abstract base 
# class for 'Missile.gd' and 'Roller.gd'. 

export var EXPLOSION_BASE_KNOCKBACK_STRENGTH = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = .5

onready var omni_light = get_node("OmniLight")

func _ready():
	add_to_group("projectiles")
	connect("body_entered", self, "on_body_entered")
	GameState.connect("state_changed", self, "on_GameState_changed")


func bid_farewell():
	pass


func on_body_entered(body):
	if body.has_method("on_hit_by_projectile"):
		body.on_hit_by_projectile(self)


func on_hit_by_bomb_explosion(var explosion_pos, var _blast_radius):
	var impulse_direction = (explosion_pos - get_global_transform().origin).normalized()
	apply_impulse(explosion_pos, impulse_direction * EXPLOSION_BASE_KNOCKBACK_STRENGTH)


func on_hit_by_missile_explosion(var explosion_pos, var _blast_radius):
	var impulse_direction = (explosion_pos - get_global_transform().origin).normalized()
	apply_impulse(explosion_pos, impulse_direction * EXPLOSION_BASE_KNOCKBACK_STRENGTH)


func on_entered_laser_area():
	bid_farewell()
	queue_free()


func on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME:
		bid_farewell()
		queue_free()
	else:
		omni_light.set_visible(new_state == GameState.ECLIPSE)
