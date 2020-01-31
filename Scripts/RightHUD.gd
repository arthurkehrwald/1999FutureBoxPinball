extends Sprite3D

const MONEY_LABEL_FORMAT_STRING = "%s,000,000,000"
const PLAYER_HEALTH_LABEL_FORMAT_STRING = "%s%"

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("player_coolness_changed", self, "_on_GameState_player_coolness_changed")
	GameState.connect("player_money_changed", self, "_on_GameState_player_money_changed")

func _ready():
	texture = $Viewport.get_texture()

func _on_GameState_global_reset(_is_init):
	pass

func _on_GameState_player_money_changed(new_player_money):
	if new_player_money == GameState.MAX_PLAYER_MONEY:
		$Viewport/RightPanel/MoneyMaxedLabel.text = "You're rich'"
		$Viewport/RightPanel/MoneyLabel.text = "1.000.000.000.000"
	elif new_player_money == 0:
		$Viewport/RightPanel/MoneyMaxedLabel.text = "You're broke'"
		$Viewport/RightPanel/MoneyLabel.text = "0"
	else:
		$Viewport/RightPanel/MoneyMaxedLabel.text = ""
		$Viewport/RightPanel/MoneyLabel.text = MONEY_LABEL_FORMAT_STRING % new_player_money

func _on_GameState_player_coolness_changed(new_player_coolness):
	$Viewport/RightPanel/CoolnessMeter.value = new_player_coolness

func _on_PlayerShip_health_changed(new_health, max_health):
	$Viewport/RightPanel/PlayerHealthBar.max_value = max_health
	$Viewport/RightPanel/PlayerHealthBar.value = new_health
	$Viewport/RightPanel/PlayerHealthLabel.text = str(round(new_health / max_health * 100)) + "%"
