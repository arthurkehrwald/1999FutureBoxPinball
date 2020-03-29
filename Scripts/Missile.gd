extends Area

export var speed = 1.0
export var chain_explosion_delay = .1

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _ready():
	$AnimationPlayer.playback_speed = speed

func _on_Missile_body_entered(body):
	explode()
	
func _on_Bomb_explosion_hit():
	explode()

func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		queue_free()
	
func explode():
	$Explosion.explode()
	$MeshInstance.set_visible(false)
	yield($Explosion, "exploded")
	queue_free()

func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
