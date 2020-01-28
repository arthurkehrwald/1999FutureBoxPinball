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
	$Viewport/ShopMenu.set_active(true)
