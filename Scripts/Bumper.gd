extends Spatial

export var BUMP_FORCE = 10.0
export var MONEY_PER_BUMP = 100
export var MONEY_TEXT_HEIGHT = 0.5

var money_text_3d_scene = preload("res://Scenes/MoneyText3D.tscn")

onready var audio_player = get_node("AudioStreamPlayer")


func on_hit_by_projectile(projectile):
	if not projectile.is_in_group("rollers"):
		return
	audio_player.play()
	projectile.set_linear_velocity(Vector3(0,0,0))
	var impulse_origin = get_global_transform().origin  + Vector3(0, .2, 0)
	var projectile_pos = projectile.get_global_transform().origin
	projectile.apply_central_impulse((projectile_pos - impulse_origin).normalized() * BUMP_FORCE)
	GameState.add_player_money(MONEY_PER_BUMP)
	var money_text_3d_instance = money_text_3d_scene.instance()
	money_text_3d_instance.set_money_amount(MONEY_PER_BUMP)
	add_child(money_text_3d_instance)
	money_text_3d_instance.translate(Vector3(0, MONEY_TEXT_HEIGHT, 0))
