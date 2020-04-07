class_name Projectile
extends RigidBody
# Notifies bodies and areas when its area hits them and calls virtual functions
# that derived classes can implement to respond to the collision. Abstract base 
# class for 'Missile.gd' and 'Roller.gd'. 

export var EXPLOSION_BASE_KNOCKBACK_STRENGTH = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = .5

onready var _hitreg_area = get_node("HitregArea")
onready var _omni_light = get_node("OmniLight")

func _ready():
	_hitreg_area.connect("area_entered", self, "_on_HitregArea_area_entered")
	_hitreg_area.connect("body_entered", self, "_on_HitregArea_body_entered")


func on_hit_by_bomb_explosion(var explosion_pos, var _blast_radius):
	var impulse_direction = (explosion_pos - get_global_transform().origin).normalized()
	apply_impulse(explosion_pos, impulse_direction * EXPLOSION_BASE_KNOCKBACK_STRENGTH)


func on_hit_by_missile_explosion(var explosion_pos, var _blast_radius):
	var impulse_direction = (explosion_pos - get_global_transform().origin).normalized()
	apply_impulse(explosion_pos, impulse_direction * EXPLOSION_BASE_KNOCKBACK_STRENGTH)


func _on_HitregArea_area_entered(_area):
	pass


func _on_HitregArea_body_entered(_body):
	pass
