extends TextureRect

var victory_texture = preload("res://HUD/victory_banner.png")
var game_over_texture = preload("res://HUD/game_over_banner.png")

func _enter_tree():
	# TODO GameState.connect("global_reset", self, "_on_GameState_global_reset")
	# TODO GameState.connect("player_died", self, "_on_GameState_player_died")
	# TODO GameState.connect("boss_died", self, "_on_GameState_boss_died")
	hide()
	
func _on_GameState_global_reset(_is_init):
	hide()
	
func _on_GameState_player_died():
	texture = game_over_texture
	show()

func _on_GameState_boss_died():
	texture = victory_texture
	show()
	
