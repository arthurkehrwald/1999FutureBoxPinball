extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()
	
func set_max_value(max_value):
	$Viewport.get_node("Bar").max_value = max_value

func _on_value_changed(new_value):
	$Viewport.get_node("Bar").value = new_value
