extends Control

const MONEY_LABEL_FORMAT_STRING = "%s,000,000,000"
const PLAYER_HEALTH_LABEL_FORMAT_STRING = "%s%"

func _enter_tree():
	#GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("player_coolness_changed", self, "_on_GameState_player_coolness_changed")
	GameState.connect("player_money_changed", self, "_on_GameState_player_money_changed")
	
func _on_GameState_player_money_changed(new_player_money):
	if new_player_money == GameState.MAX_PLAYER_MONEY:
		$Background/MoneyMaxedLabel.text = "CAP"
		$Background/MoneyLabel.text = "1.000.000.000.000"
	elif new_player_money == 0:
		$Background/MoneyMaxedLabel.text = "You're broke!"
		$Background/MoneyLabel.text = "0"
	else:
		$Background/MoneyMaxedLabel.text = ""
		$Background/MoneyLabel.text = MONEY_LABEL_FORMAT_STRING % new_player_money
	$GlitchShader.glitch_out()
	
		
func _on_GameState_player_coolness_changed(new_player_coolness):
	$Background/CoolnessMeter.value = new_player_coolness
	#$GlitchShader.glitch_out()

func _on_PlayerShip_health_changed(new_health, max_health):
	$Background/PlayerHealthBar.max_value = max_health
	$Background/PlayerHealthBar.value = new_health
	$Background/PlayerHealthLabel.text = str(round(new_health / max_health * 100)) + "%"
	$GlitchShader.glitch_out()