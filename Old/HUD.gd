extends Control

const MONEY_LABEL_FORMAT_STRING = "%s,000,000,000"

func _enter_tree():
	GameState.connect("player_coolness_changed", self, "_on_GameState_player_coolness_changed")
	GameState.connect("player_money_changed", self, "_on_GameState_player_money_changed")

func _on_GameState_player_money_changed(new_player_money):
	if new_player_money == GameState.MAX_PLAYER_MONEY:
		$RightPanel/MoneyMaxedLabel.text = "You're rich'"
		$RightPanel/MoneyLabel.text = "1.000.000.000.000"
	elif new_player_money == 0:
		$RightPanel/MoneyMaxedLabel.text = "You're broke'"
		$RightPanel/MoneyLabel.text = "0"
	else:
		$RightPanel/MoneyMaxedLabel.text = ""
		$RightPanel/MoneyLabel.text = MONEY_LABEL_FORMAT_STRING % new_player_money

func _on_GameState_player_coolness_changed(new_player_coolness):
	$RightPanel/CoolnessMeter.value = new_player_coolness

func _on_PlayerShip_health_changed(new_health, max_health):
	$RightPanel/PlayerHealthBar.max_value = max_health
	$RightPanel/PlayerHealthBar.value = new_health
