extends Sprite3D


func _ready():
	texture = $Viewport.get_texture()


func set_text(text):
	$Viewport/Label.text = text
