extends "res://Scripts/BossGun.gd"

var bomb_scene = preload("res://Scenes/Bomb.tscn")

export var bomb_muzzle_velocity = 5
export var random_direction_range = 5.0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

#func _on_HitboxArea_body_exited(body):
#	if get_collision_exceptions().has(body):
#		remove_collision_exception_with(body)

func _shoot():
	$AudioStreamPlayer.play()
	var bomb_instance = bomb_scene.instance()
	bomb_instance.set_transform($Muzzle.get_transform())
	#bomb_instance.get_node("Rigidbody").add_collision_exception_with(self)
#	self.add_collision_exception_with(bomb_instance.get_node("Rigidbody"))
#	$HitboxArea.connect("body_exited", bomb_instance.get_node("Rigidbody"), "_on_GunHitboxArea_body_exited", [self], 4)	
	add_child(bomb_instance)
	bomb_instance.set_global_transform(Transform(Basis.IDENTITY, $Muzzle.get_global_transform().origin))
	bomb_instance.apply_central_impulse(-$Muzzle.get_global_transform().rotated($Muzzle.get_global_transform().basis.y.normalized(), deg2rad(rng.randf_range(-random_direction_range, random_direction_range))).basis.z.normalized() * bomb_muzzle_velocity)
