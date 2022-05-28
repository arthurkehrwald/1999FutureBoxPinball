class_name Bumper
extends Area

signal bumpable_body_entered(bumper, body)
signal bumped(bumper, body)

export var BUMP_FORCE = 10.0
export var MONEY_PER_BUMP = 100.0
export var MONEY_TEXT_HEIGHT = 1.0

# Set to true by parent bumper cluster if it exists
var is_controlled_by_bumper_cluster = false
var bodies_moving_through_bumper = []


func _ready():
	if Globals.player_ship == null:
		push_warning("[Bumper] can't find player! Will not yield money.")
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")

func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	emit_signal("bumpable_body_entered", self, body)
	if not is_controlled_by_bumper_cluster:
		bump_towards_pos(body, body.global_transform.origin)


func on_body_exited(body):
	if bodies_moving_through_bumper.has(body):
		bodies_moving_through_bumper.erase(body)
		$StaticBody.remove_collision_exception_with(body)


func calc_impulse_dir_to_pos(pos : Vector3) -> Vector3:
	var impulse_dir = pos - global_transform.origin
	impulse_dir.y = 0
	impulse_dir = impulse_dir.normalized()
	return impulse_dir


func bump_towards_pos(body : RigidBody, pos : Vector3):
	var dir = calc_impulse_dir_to_pos(pos)
	bump_in_dir(body, dir)


func bump_in_dir(body : RigidBody, dir : Vector3):
	if (not overlaps_body(body)):
		return
	dir = dir.normalized()
	body.set_linear_velocity(Vector3(0,0,0))
	var will_bump_towards_bumper = is_dir_from_pos_facing_bumper(dir, body.global_transform.origin)
	if will_bump_towards_bumper:
		$StaticBody.add_collision_exception_with(body)
		bodies_moving_through_bumper.push_back(body)
	body.apply_central_impulse((dir).normalized() * BUMP_FORCE)
	if Globals.player_ship != null and MONEY_PER_BUMP > 0:
		Globals.player_ship.set_money(Globals.player_ship.money + MONEY_PER_BUMP)
		var money_pos = get_global_transform().origin + Vector3.UP * MONEY_TEXT_HEIGHT
		PoolManager.request(PoolManager.MONEY_TEXT, money_pos)
	var fx_pos = get_global_transform().origin + Vector3.UP * .2
	PoolManager.request(PoolManager.BUMPER_HIT, fx_pos)
	emit_signal("bumped", self, body)


func is_dir_from_pos_facing_bumper(dir : Vector3, pos : Vector3) -> bool:
	dir = dir.normalized()
	var dir_to_pos = (pos - global_transform.origin).normalized()
	var ret = dir.dot(dir_to_pos)
	return ret
