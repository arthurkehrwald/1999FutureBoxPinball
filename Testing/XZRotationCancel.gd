extends Spatial


func _ready():
	orthonormalize()
	rotate(get_transform().basis.x, -rotation.x)
	#set_transform(get_transform().rotated(Vector3(1, 0, 0), -rotation.x))
	orthonormalize()
	rotate(get_transform().basis.z, -rotation.z)
	#set_transform(get_transform().rotated(Vector3(0, 0, 1), -rotation.z))
	orthonormalize()
