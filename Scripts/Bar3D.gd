extends Sprite3D

func _ready():
	texture = $Viewport.get_texture()

func update_value(_value, _max_value):
	$Viewport/Bar.update_value(_value, _max_value)

