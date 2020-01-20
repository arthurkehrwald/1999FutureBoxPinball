extends "res://Scripts/BossGun.gd"

var bomb_scene = preload("res://Scenes/Bomb.tscn")

export var bomb_muzzle_velocity = 5

func _on_ShotTimer_timeout():
	if !stunned:
		shoot_bomb()

func _on_HitboxArea_body_exited(body):
	if get_collision_exceptions().has(body):
		remove_collision_exception_with(body)

func shoot_bomb():
	var bomb_instance = bomb_scene.instance()
	bomb_instance.set_transform($Muzzle.get_transform())
	bomb_instance.get_node("Rigidbody").add_collision_exception_with(self)
	self.add_collision_exception_with(bomb_instance.get_node("Rigidbody"))
	$HitboxArea.connect("body_exited", bomb_instance.get_node("Rigidbody"), "_on_GunHitboxArea_body_exited", [self], 4)
	add_child(bomb_instance)
	bomb_instance.get_node("Rigidbody").apply_central_impulse(-bomb_instance.get_global_transform().basis.z.normalized() * bomb_muzzle_velocity)
