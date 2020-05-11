extends Area

export var BOUNCE_FORCE = 20


func _ready():
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	PoolManager.request(PoolManager.SLINGSHOT_HIT, body.get_global_transform().origin)
	PoolManager.request(PoolManager.WIREFRAME_FLASH, body.get_global_transform().origin)
	body.set_linear_velocity(Vector3(0,0,0))
	body.apply_central_impulse(-get_global_transform().basis.z.normalized() * BOUNCE_FORCE)
