extends Spatial

var total_ship_count = 0
var remaining_ship_count = 0
var is_active = false

onready var _ship_parent = get_node("ParentForAnimation")
onready var _animation_player = get_node("AnimationPlayer")


func _ready():
	GameState.connect("state_changed", self, "_on_GameState_changed")
	total_ship_count = _ship_parent.get_child_count()
	remaining_ship_count = total_ship_count
	for ship in _ship_parent.get_children():
		ship.get_node("Damageable").connect("death", self, "_on_EnemyShip_death")


func _on_GameState_changed(new_state, _is_debug_skip):
	set_is_active(new_state == GameState.ENEMY_FLEET)


func set_is_active(value):
	is_active = value
	for ship in _ship_parent.get_children():
		if value:
			ship.get_node("Damageable").set_health(ship.get_node("Damageable").MAX_HEALTH)
		ship.get_node("Damageable").set_is_vulnerable(value)
	if _animation_player.is_playing():
		_animation_player.stop()
	if value:
		remaining_ship_count = total_ship_count
		_animation_player.play("enemy_fleet_appear_anim")
		_animation_player.queue("enemy_fleet_idle_anim")


func _on_EnemyShip_death():
	if is_active:
		remaining_ship_count -= 1
		if remaining_ship_count <= 0:
			GameState.handle_event(GameState.Event.FLEET_DEFEATED)
			set_is_active(false)
