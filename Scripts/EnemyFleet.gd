extends Spatial

signal was_set_active(is_active)

var total_ship_count = 0
var remaining_ship_count = 0
var is_active = false

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _ready():
	total_ship_count = $ParentForAnimation.get_child_count()
	remaining_ship_count = total_ship_count
	for ship in $ParentForAnimation.get_children():
		connect("was_set_active", ship, "set_alive")

func _on_GameState_stage_changed(new_stage):
	if new_stage == GameState.stage.ENEMY_FLEET:
		set_active(true)
	else:
		set_active(false)

func set_active(_is_active):
	is_active = _is_active
	print("EnemyFleet: active -", _is_active)
	emit_signal("was_set_active", _is_active)
	if $AnimationPlayer.is_playing():
		$AnimationPlayer.stop()
	if _is_active:
		remaining_ship_count = total_ship_count
		$AnimationPlayer.play("enemy_fleet_appear_anim")
		$AnimationPlayer.queue("enemy_fleet_idle_anim")

func _on_EnemyShip_death():
	if is_active:
		remaining_ship_count -= 1
		if remaining_ship_count <= 0:
			if GameState.current_state == GameState.state.ENEMY_FLEET and not GameState.is_objective_one_complete:
				GameState.on_objective_one_complete()
			set_active(false)
