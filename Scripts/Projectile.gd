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


func on_body_entered(body):
	if body.has_method("on_hit_by_projectile"):
		body.on_hit_by_projectile(self)


func on_hit_by_explosion(explosion):
	var explosion_pos = explosion.get_global_transform().origin
	var to_explosion = explosion_pos - get_global_transform().origin
	var normalized_blast_force = 1 - to_explosion.length() / explosion.blast_radius
	var b = EXPLOSION_BASE_KNOCKBACK_STRENGTH
	var d = EXPLOSION_DISTANCE_RELEVANCE
	var f = normalized_blast_force
	var knockback_strength = b * d * sin(PI * f - PI / 2) + b
	apply_central_impulse(-to_explosion.normalized() * knockback_strength)


func on_entered_laser_area():
	queue_free()


func on_GameState_changed(new_state, is_debug_skip):
	if is_debug_skip or new_state == GameState.PREGAME:
		queue_free()
	else:
		omni_light.set_visible(new_state == GameState.ECLIPSE)
