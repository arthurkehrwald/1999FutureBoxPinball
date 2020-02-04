extends MeshInstance

var white_unlit_mat = preload("res://Materials/white_unlit.tres")
var black_unlit_mat = preload("res://Materials/black_unlit.tres")

func _enter_tree():
	#GameState.connect("stage_changed", self, "_on_GameState_stage_changed")
	GameState.connect("set_collision_object_material", self, "_on_GameState_set_collision_object_material")

func _on_GameState_set_collision_object_material(material):
	set_material_override(material)
