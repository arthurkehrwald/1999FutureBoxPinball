extends Area

signal menu_triggered

export var money_required_to_open = 200

var balls_inside = []
var is_open = false

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	GameState.connect("player_money_changed", self, "_on_GameState_player_money_changed")

func _ready():
	set_process(false)
	balls_inside.resize(15)

func _process(_delta):
	if Input.is_action_pressed("shop_enter"):
		for ball in balls_inside:
			if ball != null and ball.has_method("set_linear_velocity"):
				ball.set_linear_velocity(Vector3(0, 0, 0))
		set_open(false)
		emit_signal("menu_triggered")

func _on_Shop_body_entered(body):
	if body.has_method("indicator_set_visible"):
		body.indicator_set_visible(true)
	if is_open:
		balls_inside.append(body)
		set_process(true)

func _on_Shop_body_exited(body):
	if body.has_method("indicator_set_visible"):
		body.indicator_set_visible(false)
	if balls_inside.has(body):	
		balls_inside.erase(body)
	if balls_inside.size() <= 0:
		set_process(false) 
		balls_inside.clear()
		balls_inside.resize(15)

func _on_GameState_stage_changed(new_stage, _is_debug_skip):
	if new_stage == GameState.stage.PREGAME:
		set_open(false)

func _on_GameState_player_money_changed(new_player_money):
	if not is_open and new_player_money >= money_required_to_open:
		set_open(true)
	
func set_open(_is_open):
	if _is_open:
		Announcer.say("shop_open")
	#print("Shop: open status - ", _is_open)
	balls_inside.clear()
	balls_inside.resize(15)
	set_process(false)
	is_open = _is_open
