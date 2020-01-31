extends Spatial

signal was_set_active(is_active)

var total_ship_count = 0
var remaining_ship_count = 0

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("enemy_fleet_set_active", self, "set_active")

func _ready():
	print("EnemyFleet: ready")
	total_ship_count = $ParentForAnimation.get_child_count()
	remaining_ship_count = total_ship_count
	for ship in $ParentForAnimation.get_children():
		connect("was_set_active", ship, "set_alive")

func set_active(is_active):
	print("EnemyFleet: active -", is_active)
	emit_signal("was_set_active", is_active)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if is_active:
		remaining_ship_count = total_ship_count
		$AnimationPlayer.play("enemy_fleet_appear_anim")
		$AnimationPlayer.queue("enemy_fleet_idle_anim")

func _on_GameState_global_reset(_is_init):
	set_active(false)

func _on_EnemyShip_death():
	remaining_ship_count -= 1
	if remaining_ship_count <= 0:
		GameState.on_EnemyFleet_destroyed()
