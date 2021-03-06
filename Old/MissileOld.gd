extends Area

export var speed = 1.0
export var chain_explosion_delay = .1

func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")

func _ready():
	$AnimationPlayer.playback_speed = speed

func _on_Missile_body_entered(_body):
	explode()
	
func _on_Bomb_explosion_hit():
	explode()

func _on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		queue_free()
	
func explode():
	$Explosion.explode()
	$MeshInstance.set_visible(false)
	yield($Explosion, "exploded")
	queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
