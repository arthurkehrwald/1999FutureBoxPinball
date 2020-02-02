extends Area

export var speed = 1.0
export var chain_explosion_delay = .1

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	$AnimationPlayer.playback_speed = speed

func _on_Missile_body_entered(_body):
	explode()
	
func _on_Bomb_explosion_hit():
	explode()

func _on_GameState_global_reset(is_init):
	if !is_init:
		queue_free()
	
func explode():
	$Explosion.explode()
	$MeshInstance.set_visible(false)
	yield($Explosion, "exploded")
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
