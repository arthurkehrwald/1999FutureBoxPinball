extends Camera
var headPos

func _process(delta):
	headPos = Vector3($TestUDP.xPos, $TestUDP.yPos, $TestUDP.zPos)
	#print(headPos)
	#print(get_camera_transform().origin)
	set_translation(Vector3(headPos.x, get_global_transform().origin.y,  get_global_transform().origin.z))
	set_frustum_offset(Vector2(get_global_transform().origin.x * -.31, get_global_transform().origin.z * .31))
	set_znear((get_global_transform().origin.y - 1) * .31)
	
