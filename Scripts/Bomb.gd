extends "res://Scripts/AbstractBall.gd"

export var FUSE_TIME = 5.0
export var CHAIN_EXPLOSIONS_ENABLED = true
export var CHAIN_EXPLOSION_DELAY = .2

const COLLISION_MASK_SWITCH_DELAY = 2

var is_exploding = false


func _ready():
	$Timer.set_wait_time(FUSE_TIME)
	$Timer.start()
	var switch_timer = get_tree().create_timer(COLLISION_MASK_SWITCH_DELAY)
	switch_timer.connect("timeout", self, "enable_collisions_with_boss")
#	yield(get_tree().create_timer(COLLISION_LAYER_SWITCH_DELAY), "timeout")
#	# enable collisions with the boss
#	print("Bomb: switched collision layers; can now collide with boss")
#	set_collision_mask_bit(10, true)
#	# enable collisions with the boss shield
#	set_collision_mask_bit(14, true)
#	$HitboxArea.set_deferred("monitoring", true)
##func _on_GunHitboxArea_body_exited(body, gun_static_body):
##	if body == self and get_collision_exceptions().has(gun_static_body):
##		remove_collision_exception_with(gun_static_body)


func enable_collisions_with_boss():
	set_collision_mask_bit(10, true)
	set_collision_mask_bit(14, true)
	$HitboxArea.set_deferred("monitoring", true)	


func _on_Timer_timeout():
	explode()


func _on_Bomb_explosion_hit(_explosion_pos):
	if CHAIN_EXPLOSIONS_ENABLED:
		$Timer.stop()
		$Timer.set_wait_time(CHAIN_EXPLOSION_DELAY)
		$Timer.start()


func explode():
	set_locked(true)
	$Explosion.explode()
	$BombMesh.set_visible(false)
	yield($Explosion, "exploded")
	queue_free()


#func _on_Explosion_body_entered(body):
#	print("Explosion hit: ", body.owner.name, " at pos: ", body.get_global_transform().origin)
#	raycast.cast_to = body.owner.get_global_transform().origin - get_global_transform().origin
#	raycast.force_raycast_update()
#	if !raycast.is_colliding():
#		if body.has_method("_on_Bomb_explosion_hit"):
#			body._on_Bomb_explosion_hit()
#		elif body.owner.has_method("_on_Bomb_explosion_hit"):
#			body.owner._on_Bomb_explosion_hit()
#	else:
#		print("Explosion: raycast hit")


func _on_HitboxArea_body_entered(_body):
	print("Bomb: hit damageable directly and exploded")
	explode()
