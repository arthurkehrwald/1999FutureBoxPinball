extends MeshInstance

func _enter_tree():
	GameState.connect("set_wireframe_material", self, "_on_GameState_set_wireframe_material")
	GameState.connect("toggle_nightmode", self, "_on_GameState_toggle_nightmode")
	
func _ready():
	_on_GameState_toggle_nightmode(GameState.nightmode_enabled)
	_on_GameState_set_wireframe_material(GameState.wireframe_materials[GameState.current_wireframe_material_index])
	
func _on_GameState_set_wireframe_material(material):
	if visible:
		show()
	else:
		hide()
	set_material_override(material)

func _on_GameState_toggle_nightmode(toggle):
	if toggle:
		show()
	else:
		hide()
	