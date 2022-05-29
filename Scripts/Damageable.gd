class_name Damageable
extends CollisionObject

signal is_vulnerable_changed(value)
signal health_changed(health, old_health, max_health)
signal death

export var MAX_HEALTH = 100.0
export var BASE_REGEN_PER_SEC = .0
export var PINBALL_DIRECT_HIT_BASE_DAMAGE = 10.0
export var BOMB_DIRECT_HIT_BASE_DAMAGE = 10.0
export var MISSILE_DIRECT_HIT_DAMAGE = 10.0
export var DIRECT_HIT_SPEED_RELEVANCE = 0.5
export var BOMB_EXPLOSION_BASE_DAMAGE = 10.0
export var MISSILE_EXPLOSION_BASE_DAMAGE = 10.0
export var EXPLOSION_DISTANCE_RELEVANCE = 0.5
export var MONEY_YIELD_PER_DAMAGE = 1.0
export var MONEY_TEXT_HEIGHT = 0.5
export var BOMBS_EXPLODE_ON_IMPACT = false
export var IS_VULNERABLE_PER_STAGE = {
	"0-Testing": true,
	"1-Pregame": false,
	"2-Exposition": true,
	"3-EnemyFleet": true,
	"4-BossAppears": true,
	"5-Missiles": true,
	"6-Trex": true,
	"7-BlackHole": true,
	"8-Eclipse": true,
	"9-Victory": false,
	"10-Defeat": false
}

var is_vulnerable = true setget set_is_vulnerable
var dynamic_regen_per_sec = 0.0

onready var health = MAX_HEALTH setget set_health


func _ready():
	DIRECT_HIT_SPEED_RELEVANCE = clamp(DIRECT_HIT_SPEED_RELEVANCE, 0, 1)
	GameState.connect("state_changed", self, "on_GameState_changed")
	if MONEY_YIELD_PER_DAMAGE != 0 and Globals.player_ship == null:
		push_warning("[" + name + "] can't find player ship!"
				+ " Damaging it will not yield money.")


func _process(delta):
	var regenerated_hp = BASE_REGEN_PER_SEC + dynamic_regen_per_sec
	if regenerated_hp != 0:
		heal(regenerated_hp * delta)


func set_is_vulnerable(value):
	if not(value and health <= 0):
		is_vulnerable = value
		emit_signal("is_vulnerable_changed", value)


func set_health(new_health):
	var old_health = health
	health = clamp(new_health, 0, MAX_HEALTH)
	emit_signal("health_changed", health, old_health, MAX_HEALTH)
	if health == 0:
		emit_signal("death")
		set_is_vulnerable(false)


func heal(amount):
	if is_vulnerable:
		set_health(health + amount)


func take_damage(damage):
	if is_vulnerable:
		set_health(health - damage)
		var money_yield = damage * MONEY_YIELD_PER_DAMAGE
		if Globals.player_ship != null and money_yield != 0:
			Globals.player_ship.set_money(Globals.player_ship.money + money_yield)
			var money_pos = get_global_transform().origin + Vector3.UP * MONEY_TEXT_HEIGHT
			PoolManager.request(PoolManager.MONEY_TEXT, money_pos)


func on_GameState_changed(new_state, is_debug_skip):
	set_is_vulnerable(IS_VULNERABLE_PER_STAGE[new_state.NAME])
	if new_state == GameState.PREGAME_STATE or is_debug_skip:
		set_health(MAX_HEALTH)


func calc_roller_damage(var base_damage, var normalized_projectile_speed):
	normalized_projectile_speed = clamp(normalized_projectile_speed, 0, 1)
	return base_damage * DIRECT_HIT_SPEED_RELEVANCE * sin(PI * normalized_projectile_speed - PI / 2) + base_damage


func calc_explosion_damage(var base_damage, var explosion_pos, var blast_radius):
	var dist_to_center = (explosion_pos - get_global_transform().origin).length()
	var normalized_blast_force = 1 - dist_to_center / blast_radius
	return base_damage * EXPLOSION_DISTANCE_RELEVANCE * sin(PI * normalized_blast_force - PI / 2) + base_damage


func on_hit_by_projectile(projectile):
	var damage = 0
	if projectile.is_in_group("pinballs"):
		damage = calc_roller_damage(PINBALL_DIRECT_HIT_BASE_DAMAGE,
				projectile.get_linear_velocity().length() / projectile.SPEED_LIM)
	elif projectile.is_in_group("bombs"):
		if BOMBS_EXPLODE_ON_IMPACT:
			projectile.explode()
		damage = calc_roller_damage(BOMB_DIRECT_HIT_BASE_DAMAGE,
				projectile.get_linear_velocity().length() / projectile.SPEED_LIM)
	elif projectile.is_in_group("missiles"):
		damage = MISSILE_DIRECT_HIT_DAMAGE
	else:
		return
	take_damage(damage)
	if is_vulnerable:
		PoolManager.request(PoolManager.DAMAGEABLE_HIT, projectile.get_global_transform().origin)


func on_hit_by_explosion(explosion):
	var base_damage = 0
	if explosion.is_in_group("bomb_explosions"):
		base_damage = BOMB_EXPLOSION_BASE_DAMAGE
	elif explosion.is_in_group("missile_explosions"):
		base_damage = MISSILE_EXPLOSION_BASE_DAMAGE
	take_damage(calc_explosion_damage(
			base_damage,
			explosion.get_global_transform().origin,
			explosion.blast_radius))
