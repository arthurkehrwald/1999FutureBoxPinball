extends Label

func _ready():
	text = "Money: %s"%GameState.player_money
	GameState.connect("player_money_changed", self,"_on_GameState_player_money_changed")

func _on_GameState_player_money_changed(new_player_money):
	text = "Money: %s"%new_player_money
