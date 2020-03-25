extends Spatial

func _process(_delta):
	if (Input.is_key_pressed(KEY_ALT)):
		print("RotationCancel: own rotation", rotation_degrees)
		print("RotationCancel: parent rotation", self.get_parent_spatial().rotation_degrees)
	#set_rotation(-self.get_parent_spatial().rotation)
	look_at(get_global_transform().origin + Vector3.RIGHT, Vector3.UP)
