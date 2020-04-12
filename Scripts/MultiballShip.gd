extends Spatial

const SHOT_DELAY = 1.0

export var SHOT_SPEED = 5.0

var pinballs_locked = 0
var next_muzzle_position = Vector3(0, 0, 0)
var loaded_pinballs = []
var muzzle_transforms = []

onready var entrance_area = get_node("EntranceArea")
onready var muzzle_a = get_node("ShipMesh/MuzzleA")
onready var muzzle_b = get_node("ShipMesh/MuzzleB")
onready var muzzle_c = get_node("ShipMesh/MuzzleC")

func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	entrance_area.connect("body_entered", self, "on_EntranceArea_body_entered")
	muzzle_transforms.resize(3)
	muzzle_transforms[0] = muzzle_a.get_global_transform()
	muzzle_transforms[1] = muzzle_b.get_global_transform()
	muzzle_transforms[2] = muzzle_c.get_global_transform()


func on_EntranceArea_body_entered(body):
	if not body.is_in_group("pinballs"):
		return
	loaded_pinballs.push_back(weakref(body))
	body.set_visible(false)
	body.set_locked(true)
	body.teleport(muzzle_transforms[pinballs_locked].origin)
	pinballs_locked += 1	
	if pinballs_locked >= 3:
		
		yield(get_tree().create_timer(SHOT_DELAY), "timeout")
		
		pinballs_locked = 0
		for i in range(3):
			if loaded_pinballs[i].get_ref():
				loaded_pinballs[i].get_ref().set_visible(true)
				loaded_pinballs[i].get_ref().set_locked(false)
				var impulse = -muzzle_transforms[i].basis.z.normalized() * SHOT_SPEED
				loaded_pinballs[i].get_ref().apply_central_impulse(impulse)
				loaded_pinballs[i].get_ref().set_is_accessible_to_player(true)
		Announcer.say("multiball")
	else:
		body.set_is_accessible_to_player(false)
		Announcer.say("ball_locked")


func on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		pinballs_locked = 0
		loaded_pinballs.clear()
