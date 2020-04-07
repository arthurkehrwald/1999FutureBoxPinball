extends Spatial

enum State {
	IDLE, 
	SHOOTING, 
	STUNNED
}

const RAND_REL_SHOT_DELAY = .3

export var SECONDS_BETWEEN_SHOTS = 3.0
export var IS_STUNNABLE = false
export var PINBALL_DIRECT_HIT_BASE_STUN_DUR = 10.0
export var BOMB_DIRECT_HIT_BASE_STUN_DUR = 10.0
export var MISSILE_DIRECT_HIT_BASE_STUN_DUR = 10.0
export var DIRECT_HIT_SPEED_RELEVANCE = 0.5
export var BOMB_EXPLOSION_BASE_STUN_DUR = 10.0
export var MISSILE_EXPLOSION_BASE_STUN_DUR = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = 0.5
export var  IS_SHOOTING_PER_STAGE = {
	"Testing": true,
	"Pregame": false,
	"Exposition": false,
	"EnemyFleet": false,
	"BossAppears": true,
	"Missiles": true,
	"Trex": true,
	"BlackHole": true,
	"Eclipse": true,
	"Victory": false,
	"Defeat": false
}

var EXPORT_STRING_TO_STATE_ENUM = {
	"Testing": GameState.NONE,
	"Pregame": GameState.PREGAME,
	"Exposition": GameState.EXPOSITION,
	"EnemyFleet": GameState.ENEMY_FLEET,
	"BossAppears": GameState.BOSS_APPEARS,
	"Missiles": GameState.MISSILES,
	"Trex": GameState.TREX,
	"BlackHole": GameState.BLACK_HOLE,
	"Eclipse": GameState.ECLIPSE,
	"Victory": GameState.VICTORY,
	"Defeat": GameState.DEFEAT
}
var IS_SHOOTING_PER_GAME_STATE = {}
var _state = State.IDLE

onready var _hit_notifier = get_node("HitNotifier")
onready var _timer = get_node("Timer")
onready var _shot_time_bar = get_node("ShotTimeBar3D/Viewport/Bar")
onready var _stunned_indicator = get_node("StunnedIndicator")
onready var _muzzle = get_node("Muzzle")
onready var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()
	for string_key in IS_SHOOTING_PER_STAGE.keys():
		var game_state = EXPORT_STRING_TO_STATE_ENUM[string_key]
		IS_SHOOTING_PER_GAME_STATE[game_state] = IS_SHOOTING_PER_STAGE[string_key]
	GameState.connect("state_changed", self, "_on_GameState_changed")
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_hit_notifier.connect("hit_by_pinball_directly", self, "_on_HitNotifier_hit_by_pinball_directly")
	_hit_notifier.connect("hit_by_bomb_directly", self, "_on_HitNotifier_hit_by_bomb_directly")
	_hit_notifier.connect("hit_by_missile_directly", self, "_on_HitNotifier_hit_by_missile_directly")
	_hit_notifier.connect("hit_by_bomb_explosion", self, "_on_HitNotifier_hit_by_bomb_explosion")
	_hit_notifier.connect("hit_by_missile_explosion", self, "_on_HitNotifier_hit_by_missile_explosion")


func _process(_delta):
	_shot_time_bar.value = _timer.time_left


func _shoot():
	pass


func _enter_idle_state():
	_state = State.IDLE
	_shot_time_bar.set_visible(false)
	_stunned_indicator.set_visible(false)
	set_process(false)
	_timer.stop()


func _enter_shooting_state():
	_state = State.SHOOTING
	_shot_time_bar.set_visible(true)
	_stunned_indicator.set_visible(false)
	set_process(true)
	var r_spread = rng.randf_range(-RAND_REL_SHOT_DELAY, RAND_REL_SHOT_DELAY)
	var r_shot_delay = SECONDS_BETWEEN_SHOTS + SECONDS_BETWEEN_SHOTS * r_spread
	_shot_time_bar.max_value = r_shot_delay
	_timer.start(r_shot_delay)


func _enter_stunned_state(var stun_duration):
	if stun_duration <= 0:
		return
	_state = State.STUNNED
	_shot_time_bar.set_visible(false)
	_stunned_indicator.set_visible(true)
	set_process(false)
	_timer.start(stun_duration)


func _calc_direct_hit_stun_dur(var base_stun_dur, var projectile_vel):
	var normalized_projectile_speed = projectile_vel.length() / Globals.ROLLER_TOPSPEED
	normalized_projectile_speed = clamp(normalized_projectile_speed, 0, 1)
	return base_stun_dur * DIRECT_HIT_SPEED_RELEVANCE * sin(PI * normalized_projectile_speed - PI / 2) + base_stun_dur


func _calc_explosion_stun_dur(var base_stun_dur, var explosion_pos, var blast_radius):
	var dist_to_center = (explosion_pos - get_global_transform().origin).length()
	var normalized_blast_force = 1 - dist_to_center / blast_radius
	return base_stun_dur * EXPLOSION_DISTANCE_RELEVANCE * sin(PI * normalized_blast_force - PI / 2) + base_stun_dur


func _on_Timer_timeout():
	if _state == State.SHOOTING:
		_shoot()
		var r_spread = rng.randf_range(-RAND_REL_SHOT_DELAY, RAND_REL_SHOT_DELAY)
		var r_shot_delay = SECONDS_BETWEEN_SHOTS + SECONDS_BETWEEN_SHOTS * r_spread
		_shot_time_bar.max_value = r_shot_delay
		_timer.start(r_shot_delay)
	elif _state == State.STUNNED:
		_enter_shooting_state()


func _on_GameState_changed(new_state, _is_debug_skip):
	if _state == State.IDLE:
		if IS_SHOOTING_PER_GAME_STATE[new_state]:
			_enter_shooting_state()
	else:
		if not IS_SHOOTING_PER_GAME_STATE[new_state]:
			_enter_idle_state()


func _on_HitNotifier_hit_by_pinball_directly(_pinball_pos, pinball_vel):
	_enter_stunned_state(_calc_direct_hit_stun_dur(PINBALL_DIRECT_HIT_BASE_STUN_DUR,
			pinball_vel.length()))


func _on_HitNotifier_hit_by_bomb_directly(_bomb_pos, bomb_vel):
	_enter_stunned_state(_calc_direct_hit_stun_dur(BOMB_DIRECT_HIT_BASE_STUN_DUR,
			bomb_vel))


func _on_HitNotifier_hit_by_missile_directly(_missile_pos, missile_vel):
	_enter_stunned_state(_calc_direct_hit_stun_dur(MISSILE_DIRECT_HIT_BASE_STUN_DUR,
			missile_vel))


func _on_HitNotifier_hit_by_bomb_explosion(explosion_pos, blast_radius):
	_enter_stunned_state(_calc_explosion_stun_dur(BOMB_EXPLOSION_BASE_STUN_DUR,
			explosion_pos, blast_radius))


func _on_HitNotifier_hit_by_missile_explosion(explosion_pos, blast_radius):
	_enter_stunned_state(_calc_explosion_stun_dur(MISSILE_EXPLOSION_BASE_STUN_DUR,
			explosion_pos, blast_radius))
