extends Spatial

export var BUMP_FORCE = 10.0
export var MONEY_PER_BUMP = 100

var money_text_3d_scene = preload("res://Scenes/MoneyText3D.tscn")

onready var audio_player = get_node("AudioStreamPlayer")
onready var money_text_parent = get_node("MoneyTextPos")

func _ready():
	if Globals.player_ship == null:
		push_warning("[Bumper] can't find player! Will not yield money.")
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	audio_player.play()
	body.set_linear_velocity(Vector3(0,0,0))
	var impulse_origin = get_global_transform().origin
	impulse_origin.y = 0
	var body_pos = body.get_global_transform().origin
	body_pos.y = 0
	#body.apply_impulse(impulse_origin + Vector3.UP * .2, )
	body.apply_central_impulse((body_pos - impulse_origin).normalized() * BUMP_FORCE)
	if Globals.player_ship != null:
		Globals.player_ship.set_money(Globals.player_ship.money + MONEY_PER_BUMP)
	var money_text_3d_instance = money_text_3d_scene.instance()
	money_text_3d_instance.set_money_amount(MONEY_PER_BUMP)
	money_text_parent.add_child(money_text_3d_instance)
