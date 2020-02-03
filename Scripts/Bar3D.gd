extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()

func _on_value_changed(new_value, max_value, _old_value):
	$Viewport/Bar._on_value_changed(new_value, max_value)

