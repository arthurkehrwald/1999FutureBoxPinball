extends Area

export var damage_to_player = 40
export var speed = 1.0

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	$AnimationPlayer.playback_speed = speed

func _on_Missile_body_entered(body):
	#layer 10 -> 512 is the player ship
	if body.get_collision_layer() == 512 || body.get_collision_layer() == 4:
		GameState.set_player_health(GameState.player_health - damage_to_player)
		print("player missile hit")
	#trigger explosion fx here
	self.queue_free()
	
func _on_Bomb_explosion_hit():
	#trigger explosion fx
	self.queue_free()	

func _on_GameState_global_reset():
	self.queue_free()
