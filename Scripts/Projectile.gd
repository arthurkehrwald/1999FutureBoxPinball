class_name Projectile
extends RigidBody
# Notifies bodies and areas when its area hits them and calls virtual functions
# that derived classes can implement to respond to the collision. Abstract base 
# class for 'Missile.gd' and 'Roller.gd'. 

export var EXPLOSION_BASE_KNOCKBACK_STRENGTH = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = .5

onready var omni_light = get_node("OmniLight")
onready var hitreg_area = get_node("HitregArea")


func _ready():
	add_to_group("projectiles")
	hitreg_area.connect("body_entered", self, "on_body_entered")
	hitreg_area.connect("area_entered", self, "on_area_entered")


func on_body_entered(body):
	if get_collision_exceptions().has(body) or body == self:
		return
	if body.has_method("on_hit_by_projectile"):
		body.on_hit_by_projectile(self)
		PoolManager.request(PoolManager.WIREFRAME_FLASH, get_global_transform().origin)


func on_area_entered(area):
	if area.has_method("on_hit_by_projectile"):
		area.on_hit_by_projectile(self)
		PoolManager.request(PoolManager.WIREFRAME_FLASH, get_global_transform().origin)


func on_hit_by_explosion(explosion):
	var explosion_pos = explosion.get_global_transform().origin
	var to_explosion = explosion_pos - get_global_transform().origin
	var normalized_blast_force = 1 - to_explosion.length() / explosion.blast_radius
	var b = EXPLOSION_BASE_KNOCKBACK_STRENGTH
	var d = EXPLOSION_DISTANCE_RELEVANCE
	var f = normalized_blast_force
	var knockback_strength = b * d * sin(PI * f - PI / 2) + b
	apply_central_impulse(-to_explosion.normalized() * knockback_strength)


func on_hit_by_projectile(_projectile):
	pass


func on_entered_laser_area():
	PoolManager.request(PoolManager.PROJECTILE_LASERED, get_global_transform().origin)
	queue_free()
