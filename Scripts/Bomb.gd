extends "res://Scripts/AbstractBall.gd"

export var fuse_time = 5.0
export var chain_explosions_enabled = true
export var chain_explosion_delay = .2

const COLLISION_LAYER_SWITCH_DELAY = .4

var is_exploding = false
	
func _ready():
	$Timer.set_wait_time(fuse_time)
	$Timer.start()
	yield(get_tree().create_timer(COLLISION_LAYER_SWITCH_DELAY), "timeout")
	# enable collisions with the boss
	set_collision_mask_bit(10, true)
	# enable collisions with the boss shield
	set_collision_mask_bit(14, true)
	$Area.set_deferred("monitoring", true)
#func _on_GunHitboxArea_body_exited(body, gun_static_body):
#	if body == self and get_collision_exceptions().has(gun_static_body):
#		remove_collision_exception_with(gun_static_body)
		
func _on_Timer_timeout():
	explode()
	
func _on_Bomb_explosion_hit(_explosion_pos):
	if chain_explosions_enabled:
		$Timer.stop()
		$Timer.set_wait_time(chain_explosion_delay)
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

func _on_Area_body_entered(_body):
	explode()
