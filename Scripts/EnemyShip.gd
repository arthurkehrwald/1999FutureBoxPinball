extends "res://Scripts/Damageable.gd"

const EXPLOSION_SCENE = preload("res://Scenes/Particles_Explosion_02.tscn")

export var IS_BUMPER = true
export var BUMP_FORCE = 10.0

onready var collision_shape = get_node("CollisionShape")
onready var health_bar = get_node("HealthBar3D/Viewport/Bar")
onready var audio_player = get_node("AudioStreamPlayer")

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
		#projectile.apply_central_impulse((projectile.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * BUMP_FORCE)
	var impulse_origin = get_global_transform().origin
	impulse_origin.y = 0
	var projectile_pos = projectile.get_global_transform().origin
	projectile_pos.y = 0
	#body.apply_impulse(impulse_origin + Vector3.UP * .2, )
	projectile.apply_central_impulse((projectile_pos - impulse_origin).normalized() * BUMP_FORCE)


func on_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		audio_player.play()


func on_death():
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.set_global_transform(get_global_transform())
	get_node("/root").add_child(explosion_instance)
	explosion_instance.get_node("Debris").emitting = true
	explosion_instance.get_node("Ring").emitting = true
