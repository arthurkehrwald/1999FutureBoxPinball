extends Sprite3D

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _ready():
	texture = $Viewport.get_texture()
	pass

func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.stage.PREGAME:
		$Viewport/ShopMenu.set_active(false)

func _on_Shop_menu_triggered():
	$Viewport/ObjectiveHUD.turn_off()
	$Viewport/ShopMenu.set_active(true)

func _on_ShopMenu_closed():
	$Viewport/ObjectiveHUD.set_visible(true)

func _on_Any_panel_changed():
	$Viewport/GlitchShader.glitch_out()
