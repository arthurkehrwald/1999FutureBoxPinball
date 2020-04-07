extends Spatial

export var force = 10.0
export var money_value = 100

var money_text_3d_scene = preload("res://Scenes/MoneyText3D.tscn")

onready var _hit_notifier = get_node("HitNotifier")

func _ready():
	_hit_notifier.connect("hit_by_pinball_directly", self, "_on_HitNotifier_hit_by_roller")
	_hit_notifier.connect("hit_by_bomb_directly", self, "_on_HitNotifier_hit_by_roller")


func _on_HitNotifier_hit_by_roller(roller):
	$AudioStreamPlayer.play()
	roller.set_linear_velocity(Vector3(0,0,0))
	roller.apply_central_impulse((roller.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * force)
	#GameState.set_player_money(GameState.player_money + money_value)
	GameState.add_player_money(money_value)
	var money_text_3d_instance = money_text_3d_scene.instance()
	money_text_3d_instance.set_money_amount(money_value)
	$MoneyTextPos.add_child(money_text_3d_instance)
