extends "res://Scripts/BossGun.gd"

const BOMB_SCENE = preload("res://Scenes/Bomb.tscn")
const LAUNCH_TORQUE_SPREAD = .1

export var MUZZLE_SPEED = 5.0
export var SPREAD_DEG = 5.0

#func _on_HitboxArea_body_exited(body):
#	if get_collision_exceptions().has(body):
#		remove_collision_exception_with(body)

func shoot():
	$AudioStreamPlayer.play()
	var bomb_instance = BOMB_SCENE.instance()
	var t = Transform(Basis.IDENTITY, muzzle.get_global_transform().origin)
	bomb_instance.set_global_transform(t)
	if boss != null:
		boss.add_collision_exception_with(bomb_instance)
		bomb_instance.add_collision_exception_with(boss)
	ignored_projectiles.append(bomb_instance)
	#bomb_instance.get_node("Rigidbody").add_collision_exception_with(self)
	#self.add_collision_exception_with(bomb_instance.get_node("Rigidbody"))
	#$HitboxArea.connect("body_exited", bomb_instance.get_node("Rigidbody"), "_on_GunHitboxArea_body_exited", [self], 4)	
	get_node("/root").add_child(bomb_instance)
	bomb_instance.set_global_transform(Transform(Basis.IDENTITY, muzzle.get_global_transform().origin))
	var spread = deg2rad(rng.randf_range(-SPREAD_DEG, SPREAD_DEG))
	var spread_rotation_axis = muzzle.get_global_transform().basis.y.normalized()
	var rotated_muzzle_transform = muzzle.get_global_transform().rotated(spread_rotation_axis, spread)
	bomb_instance.apply_central_impulse(-rotated_muzzle_transform.basis.z.normalized() * MUZZLE_SPEED)
	var torque_impulse = Vector3(
			rng.randf_range(-.1, .1),
			rng.randf_range(-.1, .1), 
			rng.randf_range(-.1, .1))
	bomb_instance.apply_torque_impulse(torque_impulse)


func on_body_exited(body):
	ignored_projectiles.erase(body)
