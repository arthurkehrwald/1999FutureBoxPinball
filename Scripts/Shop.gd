extends Area

signal menu_triggered

var balls_inside = 0

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("player_money_maxed", self, "_on_GameState_player_money_maxed")

func _ready():
	set_process(false)

func _process(_delta):
	if Input.is_action_pressed("shop_enter"):
		set_open(false)
		emit_signal("menu_triggered")

func _on_Shop_body_entered(_body):
	balls_inside += 1
	set_process(true)

func _on_Shop_body_exited(_body):
	balls_inside -= 1
	if balls_inside >= 0:
		set_process(false) 
		balls_inside = 0

func _on_GameState_global_reset(_is_init):
	set_open(false)

func _on_GameState_player_money_maxed():
	set_open(true)
	
func set_open(is_open):
	print("Shop: open status - ", is_open)
	balls_inside = 0
	set_process(false)
	set_deferred("monitoring", is_open)
	set_deferred("monitorable", is_open)
