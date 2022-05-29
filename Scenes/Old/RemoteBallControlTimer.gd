extends Timer

signal start

export var remote_control_duration = 15.0
export var time_left_report_rate = .1

func _enter_tree():
	GameState.connect("state_changed", self, "on_GameState_changed")
	Globals.remote_control_timer = self
	if Globals.shop_menu != null:
		Globals.shop_menu.connect("bought_remote_control", self, "on_ShopMenu_bought_remote_control")


func on_ShopMenu_bought_remote_control(var duration):
	start(duration)
	emit_signal("start")


func on_GameState_changed(new_state, is_debug_skip):
	if new_state == GameState.PREGAME_STATE or is_debug_skip:
		stop()
