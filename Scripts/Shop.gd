extends Area

signal menu_triggered

export var money_required_to_open = 200

var balls_inside = 0
var is_open = false

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("player_money_changed", self, "_on_GameState_player_money_changed")

func _ready():
	set_process(false)

func _process(_delta):
	if Input.is_action_pressed("shop_enter"):
		set_open(false)
		emit_signal("menu_triggered")

func _on_Shop_body_entered(body):
	if body.has_method("indicator_set_visible"):
		body.indicator_set_visible(true)
	if is_open:
		balls_inside += 1
		set_process(true)

func _on_Shop_body_exited(body):
	if body.has_method("indicator_set_visible"):
		body.indicator_set_visible(false)
	balls_inside -= 1
	if balls_inside >= 0:
		set_process(false) 
		balls_inside = 0

func _on_GameState_global_reset(_is_init):
	set_open(false)

func _on_GameState_player_money_changed(new_player_money):
	if not is_open and new_player_money >= money_required_to_open:
		set_open(true)
	
func set_open(_is_open):
	#print("Shop: open status - ", _is_open)
	balls_inside = 0
	set_process(false)
	is_open = _is_open