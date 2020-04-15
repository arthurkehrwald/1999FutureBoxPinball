extends "res://Scripts/Roller.gd"

const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")
const COLLISION_MASK_SWITCH_DELAY = .7

export var FUSE_TIME = 5.0

onready var timer = get_node("Timer")


func _ready():
	add_to_group("bombs")
	timer.connect("timeout", self, "on_Timer_timeout")
	timer.start(FUSE_TIME)
	#var switch_timer = get_tree().create_timer(COLLISION_MASK_SWITCH_DELAY)
	#switch_timer.connect("timeout", _hitreg_area, "set_monitoring", [true])
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


func explode():
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.add_to_group("bomb_explosions")
	explosion_instance.set_transform(Transform(Basis.IDENTITY, get_transform().origin))
	get_parent().add_child(explosion_instance)
	queue_free()


func on_Timer_timeout():
	explode()
