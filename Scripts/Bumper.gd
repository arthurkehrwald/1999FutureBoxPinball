extends StaticBody

export var force = 10.0
export var money_value = 100

var money_text_3d_scene = preload("res://Scenes/MoneyText3D.tscn")

#func _on_HitboxArea_body_entered(body):
#	$AudioStreamPlayer.play()
#	GameState.on_player_did_anything_at_all()
#	body.set_linear_velocity(Vector3(0,0,0))
#	body.apply_central_impulse((body.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * force)
#	#GameState.set_player_money(GameState.player_money + money_value)
#	GameState.add_player_money(money_value)
#	var money_text_3d_instance = money_text_3d_scene.instance()
#	money_text_3d_instance.set_money_amount(money_value)
#	$MoneyTextPos.add_child(money_text_3d_instance)
	
func on_hit_by_projectile(body):
	$AudioStreamPlayer.play()
	GameState.on_player_did_anything_at_all()
	body.set_linear_velocity(Vector3(0,0,0))
	body.apply_central_impulse((body.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * force)
	#GameState.set_player_money(GameState.player_money + money_value)
	GameState.add_player_money(money_value)
	var money_text_3d_instance = money_text_3d_scene.instance()
	money_text_3d_instance.set_money_amount(money_value)
	$MoneyTextPos.add_child(money_text_3d_instance)
