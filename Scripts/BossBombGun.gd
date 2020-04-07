extends "res://Scripts/BossGun.gd"

const BOMB_SCENE = preload("res://Scenes/Bomb.tscn")
const LAUNCH_TORQUE_SPREAD = .1

export var MUZZLE_SPEED = 5.0
export var SPREAD_DEG = 5.0

#func _on_HitboxArea_body_exited(body):
#	if get_collision_exceptions().has(body):
#		remove_collision_exception_with(body)

func _shoot():
	$AudioStreamPlayer.play()
	var bomb_instance = BOMB_SCENE.instance()
	var t = Transform(Basis.IDENTITY, _muzzle.get_global_transform().origin)
	bomb_instance.set_global_transform(t)
	#bomb_instance.get_node("Rigidbody").add_collision_exception_with(self)
#	self.add_collision_exception_with(bomb_instance.get_node("Rigidbody"))
#	$HitboxArea.connect("body_exited", bomb_instance.get_node("Rigidbody"), "_on_GunHitboxArea_body_exited", [self], 4)	
	get_node("/root").add_child(bomb_instance)
	bomb_instance.set_global_transform(Transform(Basis.IDENTITY, _muzzle.get_global_transform().origin))
	bomb_instance.apply_central_impulse(-_muzzle.get_global_transform().rotated(_muzzle.get_global_transform().basis.y.normalized(), deg2rad(rng.randf_range(-SPREAD_DEG, SPREAD_DEG))).basis.z.normalized() * MUZZLE_SPEED)
	bomb_instance.apply_torque_impulse(Vector3(rng.randf_range(-.1, .1), rng.randf_range(-.1, .1), rng.randf_range(-.1, .1)))
