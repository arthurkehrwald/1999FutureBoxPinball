extends Spatial

enum State {
	IDLE, 
	SHOOTING, 
	STUNNED
}

export var BOSS_HEALTH_START_SHOOTING_THRESHOLD = 1.0
export var SECONDS_UNTIL_FIRST_SHOT = 1.5
export var SECONDS_BETWEEN_SHOTS = 3.0
export var SECONDS_BETWEEN_SHOTS_RANDOMNESS = 0.0
export var IS_STUNNABLE = true
export var PINBALL_DIRECT_HIT_BASE_STUN_DUR = 10.0
export var BOMB_DIRECT_HIT_BASE_STUN_DUR = 10.0
export var MISSILE_DIRECT_HIT_STUN_DUR = 10.0
export var DIRECT_HIT_SPEED_RELEVANCE = 0.5
export var BOMB_EXPLOSION_BASE_STUN_DUR = 10.0
export var MISSILE_EXPLOSION_BASE_STUN_DUR = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = 0.5

var state = State.IDLE
var ignored_projectiles = []

onready var timer = get_node("Timer")
onready var shot_time_bar = get_node("ShotTimeBar3D/Viewport/Bar")
onready var stunned_indicator = get_node("StunnedIndicator")
onready var muzzle = get_node("Muzzle")
onready var rng = RandomNumberGenerator.new()


func _ready():
	if Globals.boss != null:
		Globals.boss.connect("health_changed", self, "_on_Boss_health_changed")
	else:
		push_warning("[Boss Gun] can't find Boss! Will not add collision exceptions with outgoing projectiles.")
	rng.randomize()
	timer.connect("timeout", self, "on_Timer_timeout")
	connect("body_entered", self, "on_hit_by_projectile")
	enter_idle_state()


func _process(_delta):
	shot_time_bar.value = timer.time_left


func shoot():
	pass


func enter_idle_state():
	state = State.IDLE
	shot_time_bar.set_visible(false)
	stunned_indicator.set_visible(false)
	set_process(false)
	timer.stop()


func enter_shooting_state():
	state = State.SHOOTING
	shot_time_bar.set_visible(true)
	stunned_indicator.set_visible(false)
	set_process(true)
	var randomness = SECONDS_BETWEEN_SHOTS_RANDOMNESS
	var r_spread = rng.randf_range(-randomness, randomness)
	var r_shot_delay = SECONDS_UNTIL_FIRST_SHOT + SECONDS_BETWEEN_SHOTS * r_spread
	shot_time_bar.max_value = r_shot_delay
	timer.start(r_shot_delay)


func enter_stunned_state(var stun_duration):
	if stun_duration <= 0:
		return
	state = State.STUNNED
	shot_time_bar.set_visible(false)
	stunned_indicator.set_visible(true)
	set_process(false)
	timer.start(stun_duration)


func calc_roller_stun_dur(var base_stun_dur, var normalized_projectile_speed):
	normalized_projectile_speed = clamp(normalized_projectile_speed, 0, 1)
	return base_stun_dur * DIRECT_HIT_SPEED_RELEVANCE * sin(PI * normalized_projectile_speed - PI / 2) + base_stun_dur


func calc_explosion_stun_dur(var base_stun_dur, var explosion_pos, var blast_radius):
	var dist_to_center = (explosion_pos - get_global_transform().origin).length()
	var normalized_blast_force = 1 - dist_to_center / blast_radius
	return base_stun_dur * EXPLOSION_DISTANCE_RELEVANCE * sin(PI * normalized_blast_force - PI / 2) + base_stun_dur


func on_Timer_timeout():
	if state == State.SHOOTING:
		shoot()
		var randomness = SECONDS_BETWEEN_SHOTS_RANDOMNESS
		var r_spread = rng.randf_range(-randomness, randomness)
		var r_shot_delay = SECONDS_BETWEEN_SHOTS + SECONDS_BETWEEN_SHOTS * r_spread
		shot_time_bar.max_value = r_shot_delay
		timer.start(r_shot_delay)
	elif state == State.STUNNED:
		enter_shooting_state()


func on_hit_by_projectile(projectile):
	if state == State.IDLE or !IS_STUNNABLE or ignored_projectiles.has(projectile):
		return
	var stun_dur = 0
	if projectile.is_in_group("pinballs"):
		stun_dur = calc_roller_stun_dur(PINBALL_DIRECT_HIT_BASE_STUN_DUR,
				projectile.get_linear_velocity().length() / projectile.SPEED_LIM)
	elif projectile.is_in_group("bombs"):
		stun_dur = calc_roller_stun_dur(BOMB_DIRECT_HIT_BASE_STUN_DUR,
				projectile.get_linear_velocity().length() / projectile.SPEED_LIM)
	elif projectile.is_in_group("missiles"):
		stun_dur = MISSILE_DIRECT_HIT_STUN_DUR
	else:
		return
	enter_stunned_state(stun_dur)


func on_hit_by_explosion(explosion):
	if !IS_STUNNABLE:
		return
	var base_stun_dur = 0
	if explosion.is_in_group("bomb_explosions"):
		base_stun_dur = BOMB_EXPLOSION_BASE_STUN_DUR
	elif explosion.is_in_group("missile_explosions"):
		base_stun_dur = MISSILE_EXPLOSION_BASE_STUN_DUR
	enter_stunned_state(calc_explosion_stun_dur(
			base_stun_dur,
			explosion.get_global_transform().origin,
			explosion.blast_radius))


func _on_Boss_health_changed(new_health, old_health, max_health):
	var health_normalized = new_health / max_health
	var should_be_shooting = health_normalized <= BOSS_HEALTH_START_SHOOTING_THRESHOLD
	if state == State.IDLE and should_be_shooting:
		enter_shooting_state()
	elif state != State.IDLE and not should_be_shooting:
		enter_idle_state()

func _on_Boss_is_vulnerable_changed(value):
	if !value and state != State.IDLE:
		enter_idle_state()
