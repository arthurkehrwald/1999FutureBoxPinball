extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()

func _on_value_changed(new_value, max_value):
	$Viewport/Bar.max_value = max_value
	$Viewport/Bar.value = new_value

