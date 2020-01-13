extends RigidBody

export var fuse_time = 5
export var damage_to_player = 10
export var damage_to_boss = 10

const explosion_hitreg_duration = .1

var is_exploding = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	
func _ready():
	$Timer.wait_time = fuse_time
	$Timer.start()

func _on_Timer_timeout():
	if is_exploding:
		self.queue_free()
	else:
		is_exploding = true
		$ExplosionArea.monitoring = true
		$Timer.wait_time = explosion_hitreg_duration
		$Timer.start()
	
func _on_ExplosionArea_body_entered(body):
	if body.get_collision_layer() == 1024:
		GameState.set_boss_health(GameState.boss_health - damage_to_boss)
		print ("boss go boom")
		return
		
	if body.get_collision_layer() == 512:
		GameState.set_player_health(GameState.player_health - damage_to_player)
		print ("player go boom")
		return
	
func _on_GameState_global_reset():
	self.queue_free()
