extends Sprite3D

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	texture = $Viewport.get_texture()
	pass

func _on_GameState_global_reset(_is_init):
	$Viewport/ShopMenu.set_active(false)
	pass
	
func _on_Shop_menu_triggered():
	$Viewport/ObjectiveHUD.set_visible(false)
	$Viewport/ShopMenu.set_active(true)

func _on_ShopMenu_closed():
	$Viewport/ObjectiveHUD.set_visible(true)

func _on_Any_panel_changed():
	$Viewport/GlitchShader.glitch_out()
