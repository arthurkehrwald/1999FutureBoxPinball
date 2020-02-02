extends Camera


func _process(delta):
	set_frustum_offset(Vector2(get_global_transform().origin.x * -.31, get_global_transform().origin.z * .31))
	set_znear((get_global_transform().origin.y - 1) * .31)



#func _on_UPD_ready():
	#var headPosX = $UDP.xPos
	#var headPosY = $UDP.yPos
	#var headPosZ = $UDP.zPos
	#print(Vector3(headPosX, headPosY, headPosZ))
	
