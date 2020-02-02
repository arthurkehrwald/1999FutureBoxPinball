extends Area

export var damage_to_player = 40
export var speed = 1.0

var explosion_scene = preload("res://Scenes/Explosion.tscn")

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	$AnimationPlayer.playback_speed = speed

func _on_Missile_body_entered(_body):
	
	self.queue_free()
	
func _on_Bomb_explosion_hit():
	#trigger explosion fx
	self.queue_free()	

func _on_GameState_global_reset():
	var explosion_instance = explosion_scene.instance()
	get_node("/root").add_child(explosion_instance)
	explosion_instance.set_global_transform(get_global_transform())
	explosion_instance.init(explosion_instance.explosion_type.BOMB)
	self.queue_free()
