extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()
	
func set_max_health(max_health):
	$Viewport.get_node("Bar").max_value = max_health

func _on_health_changed(new_health):
	$Viewport.get_node("Bar").value = new_health
