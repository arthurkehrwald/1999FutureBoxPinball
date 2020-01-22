extends StaticBody

export var muzzle_velocity = 10

var balls_locked = 0
var next_muzzle_position = Vector3(0, 0, 0)
var loaded_balls = []
var muzzle_transforms = []

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	muzzle_transforms.resize(3)
	muzzle_transforms[0] = $Muzzle0.get_global_transform()
	muzzle_transforms[1] = $Muzzle1.get_global_transform()
	muzzle_transforms[2] = $Muzzle2.get_global_transform()

func _on_Area_body_entered(body):
	print(balls_locked)
	loaded_balls[balls_locked] = body
	body.set_visible(false)
	body.set_locked(true)
	body.teleport(muzzle_transforms[balls_locked].origin, false, Vector3(0, 0, 0))
	GameState.balls_on_field -= 1	
	balls_locked += 1
	if balls_locked >= 3:
		balls_locked = 0
		for i in range(3):
			loaded_balls[i].set_visible(true)
			loaded_balls[i].set_locked(false)
			loaded_balls[i].apply_central_impulse(-muzzle_transforms[i].basis.z.normalized() * muzzle_velocity)
		GameState.balls_on_field += 3
	else:
		GameState._on_MultiballShip_ball_locked()

func _on_GameState_global_reset():
	balls_locked = 0
	loaded_balls.clear()
	loaded_balls.resize(3)
