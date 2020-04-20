extends Sprite3D

func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")

func _ready():
	texture = $Viewport.get_texture()
	pass

func _on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		$Viewport/ShopMenu.set_is_active(false)

func _on_Shop_menu_triggered():
	$Viewport/ObjectiveHUD.turn_off()
	$Viewport/ShopMenu.set_is_active(true)

func _on_ShopMenu_closed():
	$Viewport/ObjectiveHUD.set_visible(true)

func _on_Any_panel_changed():
	$Viewport/GlitchShader.glitch_out()
