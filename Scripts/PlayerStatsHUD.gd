extends Control

const MONEY_LABEL_FORMAT_STRING = "%s,000,000,000"
const PLAYER_HEALTH_LABEL_FORMAT_STRING = "%s%"

func _enter_tree():
	GameState.connect("player_coolness_changed", self, "_on_GameState_player_coolness_changed")
	GameState.connect("player_money_changed", self, "update_money_display")
	
func _ready():
	update_money_display(GameState.START_PLAYER_MONEY)
	
func update_money_display(new_amount):
	if new_amount == 0:
		$Background/MoneyMaxedLabel.text = "You're broke!"	
		$Background/MoneyLabel.text = "0"
	else:
		$Background/MoneyLabel.text = MONEY_LABEL_FORMAT_STRING % int(new_amount)
		if new_amount == GameState.MAX_PLAYER_MONEY:
			$Background/MoneyMaxedLabel.text = "CAP"
		else:
			$Background/MoneyMaxedLabel.text = ""
	$GlitchShader.glitch_out()
	
		
func _on_GameState_player_coolness_changed(new_player_coolness):
	$Background/CoolnessMeter.value = new_player_coolness
	#$GlitchShader.glitch_out()

func _on_PlayerShip_health_changed(new_health, max_health, old_health):
	if new_health < old_health:
		Announcer.say("ouch")
		$AudioStreamPlayer.play()
	$Background/PlayerHealthBar.max_value = max_health
	$Background/PlayerHealthBar.value = new_health
	$Background/PlayerHealthLabel.text = str(round(new_health / max_health * 100)) + "%"
	$GlitchShader.glitch_out()
