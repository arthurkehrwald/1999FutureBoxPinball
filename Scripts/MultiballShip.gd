extends StaticBody

export var muzzle_velocity = 5

var next_muzzle_index = 0
var next_muzzle_position = Vector3(0, 0, 0)
var loaded_balls = []
var muzzle_transforms = []

func _ready():
	muzzle_transforms[0] = $Muzzle0.get_global_transform()
	muzzle_transforms[1] = $Muzzle1.get_global_transform()
	muzzle_transforms[2] = $Muzzle2.get_global_transform()

func _on_Area_body_entered(body):
	loaded_balls.append(body)
	body.set_visible(false)
	body.set_locked(true)
	body.teleport(muzzle_transforms[next_muzzle_index].origin, false, Vector3(0, 0, 0))
	next_muzzle_index += 1
	if next_muzzle_index >= muzzle_transforms.size():
		next_muzzle_index = 1
		for i in loaded_balls:
			loaded_balls[i].set_visible(true)
			loaded_balls[i].set_locked(false)
			loaded_balls[i].apply_central_impulse(-muzzle_transforms[i].basis.z.normalized() * muzzle_velocity)
