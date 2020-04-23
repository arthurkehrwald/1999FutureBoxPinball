extends "res://Scripts/Damageable.gd"

export var IS_BUMPER = true
export var BUMP_FORCE = 10.0

onready var collision_shape = get_node("CollisionShape")
onready var health_bar = get_node("HealthBar3D/Viewport/Bar")
onready var hit_audio_player = get_node("HitAudioPlayer")


func _ready():
	connect("is_vulnerable_changed", self, "on_is_vulnerable_changed")
	connect("is_vulnerable_changed", health_bar, "set_visible")
	connect("health_changed", health_bar, "update_value")
	connect("health_changed", self, "on_health_changed")
	connect("death", self, "on_death")


func on_is_vulnerable_changed(value):
	set_visible(value)
	collision_shape.set_deferred("disabled", not value)


func on_hit_by_projectile(projectile):
	.on_hit_by_projectile(projectile)
	if (IS_BUMPER):
		projectile.set_linear_velocity(Vector3(0,0,0))
		var pos = get_global_transform().origin
		pos.y = 0
		var proj_pos = projectile.get_global_transform().origin
		proj_pos.y = 0
		projectile.apply_central_impulse((proj_pos - pos).normalized() * BUMP_FORCE)


func on_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		hit_audio_player.play()


func on_death():
	PoolManager.request(PoolManager.ENEMY_EXPLOSION, get_global_transform().origin)
