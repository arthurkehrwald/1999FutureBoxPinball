extends "res://Scripts/BallBombCommon.gd"

export var fuse_time = 5
export var chain_explosions_enabled = true
export var chain_explosion_delay = .2

const explosion_hitreg_duration = .1

var is_exploding = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _ready():
	$Timer.set_wait_time(fuse_time)
	$Timer.start()
	
func _on_GunHitboxArea_body_exited(body, gun_static_body):
	if body == self and get_collision_exceptions().has(gun_static_body):
		remove_collision_exception_with(gun_static_body)
		
func _on_Timer_timeout():
	if is_exploding:
		owner.queue_free()
	else:
		is_exploding = true
		$Explosion.monitoring = true
		$Timer.wait_time = explosion_hitreg_duration
		$Timer.start()
	
func _on_Explosion_body_entered(body):
	if body != self and body.has_method("_on_Bomb_explosion_hit"):
		body._on_Bomb_explosion_hit()
	
func _on_Bomb_explosion_hit():
	if chain_explosions_enabled:
		$Timer.stop()
		$Timer.set_wait_time(chain_explosion_delay)
		$Timer.start()
	
func _on_GameState_global_reset():
	owner.queue_free()
	pass
