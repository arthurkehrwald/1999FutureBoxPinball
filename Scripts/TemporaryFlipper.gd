extends "res://Scripts/Flipper.gd"

export var duration = 15.0

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	$Timer.set_wait_time(duration)

func _process(_delta):
	$Bar3D._on_value_changed($Timer.time_left, duration)

func set_active(is_active):
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
	
func _on_GameState_global_reset(_is_init):
	set_active(false)
	
func _on_ShopMenu_bought_flipper():
	if $Timer.is_stopped():
		set_active(true)
	else:
		$Timer.stop()
		$Timer.start()

func _on_Timer_timeout():
	set_active(false)
