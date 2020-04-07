extends Spatial

export var IS_BUMPER = true
export var BUMP_FORCE = 10.0

onready var _collision_shape = get_node("HitNotifier/CollisionShape")
onready var _damageable = get_node("Damageable")
onready var _health_bar = get_node("HealthBar3D/Viewport/Bar")
onready var _audio_stream_player = get_node("AudioStreamPlayer")

func _ready():
	_damageable.connect("is_vulnerable_changed", self, "_on_Damageable_is_vulnerable_changed")
	_damageable.connect("health_changed", _health_bar, "update_value")
	_damageable.connect("health_changed", self, "_on_Damageable_health_changed")


func _on_Damageable_is_vulnerable_changed(value):
	set_visible(value)
	_collision_shape.set_deferred("disabled", not value)


func _on_hit_by_projectile(projectile):
	if (IS_BUMPER):
		projectile.set_linear_velocity(Vector3(0,0,0))
		projectile.apply_central_impulse((projectile.get_global_transform().origin - (get_global_transform().origin  + Vector3(0, .2, 0))).normalized() * BUMP_FORCE)


func _on_Damageable_health_changed(current_health, old_health, _max_health):
	if current_health < old_health:
		$AudioStreamPlayer.play()
