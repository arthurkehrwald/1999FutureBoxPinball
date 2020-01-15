extends RigidBody

export var fuse_time = 5
export var chain_explosion_delay = .2

const explosion_hitreg_duration = .1

var is_exploding = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _ready():
	add_collision_exception_with($ExplosionArea)
	$Timer.wait_time = fuse_time
	$Timer.start()
	
func _on_GunHitboxArea_body_exited(body, gun_static_body):
	if body == self and get_collision_exceptions().has(gun_static_body):
		remove_collision_exception_with(gun_static_body)
		
func _on_Timer_timeout():
	if is_exploding:
		self.queue_free()
	else:
		is_exploding = true
		$ExplosionArea.monitoring = true
		$Timer.wait_time = explosion_hitreg_duration
		$Timer.start()
	
func _on_ExplosionArea_body_entered(body):
	body._on_Bomb_explosion_hit()
	
func _on_Bomb_explosion_hit():
	$Timer.stop()
	$Timer.wait_time(chain_explosion_delay)
	$Timer.start()
	
func _on_GameState_global_reset():
	self.queue_free()
