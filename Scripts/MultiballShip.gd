extends Spatial

export var muzzle_velocity = 10

var pinballs_locked = 0
var next_muzzle_position = Vector3(0, 0, 0)
var loaded_pinballs = []
var muzzle_transforms = []


func _ready():
	GameState.connect("state_changed", self, "_on_GameState_changed")
	loaded_pinballs.resize(3)
	muzzle_transforms.resize(3)
	muzzle_transforms[0] = $Muzzle0.get_global_transform()
	muzzle_transforms[1] = $Muzzle1.get_global_transform()
	muzzle_transforms[2] = $Muzzle2.get_global_transform()


func _on_HitNotifier_hit_by_pinball(pinball):
	loaded_pinballs[pinballs_locked] = weakref(pinball)
	pinball.set_visible(false)
	pinball.set_locked(true)
	pinball.delayed_teleport(muzzle_transforms[pinballs_locked].origin)
	pinball.set_is_accessible_to_player(false)
	pinballs_locked += 1
	if pinballs_locked >= 3:
		pinballs_locked = 0
		for i in range(3):
			if loaded_pinballs[i].get_ref():
				loaded_pinballs[i].get_ref().set_visible(true)
				loaded_pinballs[i].get_ref().set_locked(false)
				loaded_pinballs[i].get_ref().apply_central_impulse(-muzzle_transforms[i].basis.z.normalized() * muzzle_velocity)
				loaded_pinballs[i].get_ref().set_is_accessible_to_player(true)
		Announcer.say("multiball")
	else:
		Announcer.say("ball_locked")


func _on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		pinballs_locked = 0
		loaded_pinballs.clear()
		loaded_pinballs.resize(3)
