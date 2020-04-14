extends Sprite3D


func _ready():
	texture = $Viewport.get_texture()


func _input(event):
	$Viewport.input(event)
