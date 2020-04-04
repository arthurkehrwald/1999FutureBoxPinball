extends "res://Scripts/Flipper.gd"

export var duration = 15.0

func _enter_tree():
	GameState.connect("stage_changed", self, "_on_GameState_stage_changed")

func _ready():
	$Timer.set_wait_time(duration)

func _process(_delta):
	$Bar3D.update_value($Timer.time_left, duration)
	
func _on_GameState_stage_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		set_is_active(false)

func set_is_active(is_active):
	set_physics_process(is_active)
	set_process(is_active)
	set_visible(is_active)
	if is_active:
		$Timer.start()
	else:
		$Timer.stop()
	$CollisionShape.set_deferred("disabled", !is_active)
	$CollisionShape2.set_deferred("disabled", !is_active)
	$CollisionShape3.set_deferred("disabled", !is_active)
	$CollisionShape4.set_deferred("disabled", !is_active)
	
func _on_ShopMenu_bought_flipper():
	if $Timer.is_stopped():
		set_is_active(true)
	else:
		$Timer.stop()
		$Timer.start()

func _on_Timer_timeout():
	set_is_active(false)
