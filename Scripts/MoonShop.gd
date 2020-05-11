extends Spatial
# The mobile, partially transparent part of the moon:
#-  If player has enough money, scales up, spins and activates shop roulette when hit


enum In {
	SCALE_ANIM_DONE,
	STOPPED_SPINNING,
	HIT_BY_PROJECTILE
}
enum ScaleState {
	SMALL,
	BIG,
	SCALING_UP,
	SCALING_DOWN
}

export var MONEY_INCREASE_TO_OPEN = 200.0
export var SPIN_SPEED_MULTIPLIER = .3
export var SPIN_SPEED_FALLOFF = .5
export var IMPULSE_STRENGTH = 3.0

var is_open = true setget set_is_open
var unlock_progress = 0
var scale_state = ScaleState.SMALL
var is_spinning = false
var spin_speed = 0.0
var spin_axis = Vector3(1, 0, 0)

onready var scale_anim_player = get_node("ScaleAnimPlayer")
onready var spinning_mesh = get_node("SpinPivot/SpinningMesh")


func _ready():
	GameState.connect("state_changed", self, "on_GameState_changed")
	if Globals.player_ship != null:
		Globals.player_ship.connect("money_changed", self, "on_Player_money_changed")
	else:
		push_warning("[MoonShop] Can't find player ship! Won't be able to open"
				+ " because player's money is unknown.")
	if Globals.powerup_roulette == null:
		push_warning("[MoonShop] Can't find powerup roulette! Will not activate it.")
	scale_anim_player.connect("animation_finished", self, "on_ScaleAnimPlayer_animation_finished")
	set_process(false)


func _process(delta):
	if spin_speed > 0:
		spin(delta)
	else:
		is_spinning = false
		set_process(false)
		if scale_state == ScaleState.BIG or scale_state == ScaleState.SCALING_UP:
			scale_down()


func on_hit_by_projectile(var projectile):
	if not is_open or not projectile.is_in_group("pinballs"):
		return
	var projectile_pos = projectile.get_global_transform().origin
	var projectile_vel = projectile.get_linear_velocity()
	start_spinning(projectile_pos, projectile_vel)
	if scale_state == ScaleState.SCALING_DOWN or scale_state == ScaleState.SMALL:
		scale_up()
	PoolManager.request(PoolManager.MOON_TRIGGERED, get_global_transform().origin)
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.set_is_active(true, projectile)
	set_is_open(false)


func start_spinning(var projectile_pos, var projectile_vel):
	var colliding_body_to_moon = spinning_mesh.get_global_transform().origin - projectile_pos
	spin_axis = projectile_vel.cross(colliding_body_to_moon).normalized()
	spin_speed = projectile_vel.length() * SPIN_SPEED_MULTIPLIER
	is_spinning = true
	set_process(true)


func spin(var delta):
	spinning_mesh.set_transform(
			spinning_mesh.get_transform().rotated(spin_axis, spin_speed * TAU * delta))
	spin_speed -= SPIN_SPEED_FALLOFF * delta


func scale_up():
	scale_state = ScaleState.SCALING_UP
	scale_anim_player.play("moon_scale")
	spinning_mesh.set_visible(true)


func scale_down():
	scale_state = ScaleState.SCALING_DOWN
	scale_anim_player.play_backwards("moon_scale")


func on_ScaleAnimPlayer_animation_finished(_anim_name):
	if scale_state == ScaleState.SCALING_UP:
		if is_spinning:
			scale_state = ScaleState.BIG
		else:
			scale_down()
	elif scale_state == ScaleState.SCALING_DOWN:
		scale_state = ScaleState.SMALL
		spinning_mesh.set_visible(false)


func on_GameState_changed(new_state, is_debug_skip):
	if new_state <= GameState.PREGAME:
		set_is_open(true)
	elif is_debug_skip:
		set_is_open(false)
	if new_state == GameState.PREGAME or is_debug_skip:
		is_spinning = false
		scale_state = ScaleState.SMALL
		scale_anim_player.stop()
		spinning_mesh.set_visible(false)


func set_is_open(value):
	unlock_progress = 0
	is_open = value


func on_Player_money_changed(new, old):
	if new <= old:
		return
	unlock_progress += (new - old) / MONEY_INCREASE_TO_OPEN
	if unlock_progress <= 1:
		Announcer.say("shop_open", true)
		set_is_open(true)
