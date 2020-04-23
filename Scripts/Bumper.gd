extends Spatial

export var BUMP_FORCE = 10.0
export var MONEY_PER_BUMP = 100.0
export var MONEY_TEXT_HEIGHT = 1.0


func _ready():
	if Globals.player_ship == null:
		push_warning("[Bumper] can't find player! Will not yield money.")
	connect("body_entered", self, "on_body_entered")


func on_body_entered(body):
	if not body.is_in_group("rollers"):
		return
	body.set_linear_velocity(Vector3(0,0,0))
	var impulse_dir = body.get_global_transform().origin - get_global_transform().origin
	impulse_dir.y = 0
	body.apply_central_impulse((impulse_dir).normalized() * BUMP_FORCE)
	if Globals.player_ship != null and MONEY_PER_BUMP > 0:
		Globals.player_ship.set_money(Globals.player_ship.money + MONEY_PER_BUMP)
		var money_pos = get_global_transform().origin + Vector3.UP * MONEY_TEXT_HEIGHT
		PoolManager.request(PoolManager.MONEY_TEXT, money_pos)
	var fx_pos = get_global_transform().origin + Vector3.UP * .2
	PoolManager.request(PoolManager.BUMPER_HIT, fx_pos)
