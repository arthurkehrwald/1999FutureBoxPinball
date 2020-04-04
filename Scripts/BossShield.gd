extends "res://Scripts/Damageable.gd"

export var REGENERATION_TIME = 20.0


func _ready():
	set_process(false)


func is_active_changed():
	if is_active:
		set_visible(true)
	#print("boss shield: active - ", is_active)
	$MeshInstance.set_visible(is_active)
	$StaticBody/CollisionShape.set_deferred("disabled", !is_active)
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	set_process(!is_active)


func health_changed(_old_health):
	$HealthBar3D/Viewport/Bar.update_value(current_health)


func _process(delta):
	if REGENERATION_TIME == 0:
		set_is_active(true)
		return	
	set_health(current_health + delta / REGENERATION_TIME)
