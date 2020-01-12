extends MeshInstance

func _enter_tree():
	GameState.connect("set_collision_object_material", self, "_on_GameState_set_collision_object_material")

func _on_GameState_set_collision_object_material(material):
	set_material_override(material)
