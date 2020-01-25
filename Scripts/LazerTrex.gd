extends "res://Scripts/Damageable.gd"

export var laser_uptime = 3.0
export var laser_downtime = 5.0

export var laser_is_active = false
export var time_until_laser_toggle = 0.0

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("laser_trex_set_active", self, "_on_GameState_laser_trex_set_active")

func _ready():
	$HealthBar3D.set_max_health(max_health)

func _process(delta):
	time_until_laser_toggle -= delta
	if time_until_laser_toggle <= 0:
		laser_set_active(!laser_is_active)
	pass	
	
func _on_GameState_laser_trex_set_active(is_active):
	set_alive(true)

func _on_GameState_global_reset():
	set_alive(false)	
		
func _on_LaserTrex_came_to_life():
	set_active(true)

func _on_LaserTrex_death():
	set_active(false)

func set_active(is_active):
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	$HealthBar3D.set_visible(is_active)
	laser_set_active(false)
	set_process(is_active)

func laser_set_active(is_active):
	$LaserArea.set_deferred("monitoring", is_active)
	$LaserArea.set_deferred("monitorable", is_active)
	$LaserArea.set_visible(is_active)
	time_until_laser_toggle = laser_uptime if is_active else laser_downtime
	laser_is_active = is_active
