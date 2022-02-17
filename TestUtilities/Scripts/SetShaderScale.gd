tool
extends MeshInstance

func _process(_delta):
	var scale = global_transform.basis.get_scale() * get_node("..").grid_scale;
	var scaleXY = Vector2(scale.x, scale.y);
	get_surface_material(0).set("shader_param/scale", scaleXY);
