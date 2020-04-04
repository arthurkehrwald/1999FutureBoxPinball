extends "res://Scripts/Roller.gd"

const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")
const COLLISION_MASK_SWITCH_DELAY = .7

export var FUSE_TIME = 5.0
export var CHAIN_EXPLOSIONS_ENABLED = true
export var CHAIN_EXPLOSION_DELAY = .2

onready var _timer = get_node("Timer")


func _ready():
	_hitreg_area.set_deferred("monitoring", false)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.start(FUSE_TIME)
	var switch_timer = get_tree().create_timer(COLLISION_MASK_SWITCH_DELAY)
	switch_timer.connect("timeout", self, "enable_collisions_with_boss")
#	yield(get_tree().create_timer(COLLISION_LAYER_SWITCH_DELAY), "timeout")
#	# enable collisions with the boss
#	print("Bomb: switched collision layers; can now collide with boss")
#	set_collision_mask_bit(10, true)
#	# enable collisions with the boss shield
#	set_collision_mask_bit(14, true)
#	$HitboxArea.set_deferred("monitoring", true)
#	func _on_GunHitboxArea_body_exited(body, gun_static_body):
#	if body == self and get_collision_exceptions().has(gun_static_body):
#		remove_collision_exception_with(gun_static_body)


func enable_collisions_with_boss():
	_hitreg_area.set_deferred("monitoring", true)	


func on_hit_by_explosion():
	if CHAIN_EXPLOSIONS_ENABLED:
		_timer.start(CHAIN_EXPLOSION_DELAY)


func _explode():
	get_parent().add_child(EXPLOSION_SCENE.instance())
	queue_free()


func _on_Timer_timeout():
	_explode()


func _on_HitregArea_area_entered(area):
	if area.has_method("on_hit_by_bomb_directly"):
		area.on_hit_by_bomb_directly(get_global_transform().origin,
				get_linear_velocity())


func _on_HitregArea_body_entered(body):
	if body.has_method("on_hit_by_bomb_directly"):
		body.on_hit_by_bomb_directly(get_global_transform().origin,
				get_linear_velocity())
	_explode()
