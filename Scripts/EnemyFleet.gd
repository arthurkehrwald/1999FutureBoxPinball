extends Spatial

signal is_active_changed(value)

var total_ship_count = 0
var remaining_ship_count = 0
var is_active = false


func _ready():
	GameState.connect("state_changed", self, "_on_GameState_changed")
	total_ship_count = $ParentForAnimation.get_child_count()
	remaining_ship_count = total_ship_count
	for ship in $ParentForAnimation.get_children():
		connect("is_active_changed", ship, "_on_EnemyFleet_is_active_changed")
		ship.connect("death", self, "_on_EnemyShip_death")


func _on_GameState_changed(new_state, _is_debug_skip):
	set_is_active(new_state == GameState.ENEMY_FLEET)


func set_is_active(value):
	is_active = value
	emit_signal("was_set_is_active", value)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if value:
		remaining_ship_count = total_ship_count
		$AnimationPlayer.play("enemy_fleet_appear_anim")
		$AnimationPlayer.queue("enemy_fleet_idle_anim")


func _on_EnemyShip_death():
	if is_active:
		remaining_ship_count -= 1
		if remaining_ship_count <= 0:
			GameState.handle_event(GameState.Event.FLEET_DEFEATED)
			set_is_active(false)
