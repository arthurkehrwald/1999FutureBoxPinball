extends "res://Scripts/BallBombCommon.gd"

var explosion_scene = preload("res://Scenes/Explosion.tscn")

export var fuse_time = 5.0
export var chain_explosions_enabled = true
export var chain_explosion_delay = .2

const EXPLOSION_HITREG_DURATION = .1
const COLLISION_LAYER_SWITCH_DELAY = .4

var is_exploding = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _ready():
	$Timer.set_wait_time(fuse_time)
	$Timer.start()
	yield(get_tree().create_timer(COLLISION_LAYER_SWITCH_DELAY), "timeout")
	set_collision_mask_bit(10, true)
	set_collision_mask_bit(14, true)
	
#func _on_GunHitboxArea_body_exited(body, gun_static_body):
#	if body == self and get_collision_exceptions().has(gun_static_body):
#		remove_collision_exception_with(gun_static_body)
		
func _on_Timer_timeout():
	explode()
	
func _on_Bomb_explosion_hit():
	if chain_explosions_enabled:
		$Timer.stop()
		$Timer.set_wait_time(chain_explosion_delay)
		$Timer.start()

func _on_LaserTrex_hit():
	if !is_exploding:
		explode()

func _on_GameState_global_reset(is_init):
	if !is_init:
		owner.queue_free()

func explode():
	var explosion_instance = explosion_scene.instance()
	get_node("/root").add_child(explosion_instance)
	explosion_instance.set_global_transform(get_global_transform())
	explosion_instance.init(explosion_instance.explosion_type.BOMB)
	owner.queue_free()
