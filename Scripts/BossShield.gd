extends "res://Scripts/Damageable.gd"

export var regeneration_time = 20.0


func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")
	GameState.connect("pregame_began", self, "set_visible", [false])
	GameState.connect("bossfight_began", self, "set_alive", [true])
	
func _ready():
	set_process(false)

func _on_GameState_global_reset(is_init):
	if not is_init:
		set_process(false)

func _on_BossShield_came_to_life():
	set_active(true)

func _on_BossShield_death():
	set_active(false)

func set_active(is_active):
	if is_active:
		set_visible(true)
	print("boss shield: active - ", is_active)
	$MeshInstance.set_visible(is_active)
	$StaticBody/CollisionShape.set_deferred("disabled", !is_active)
	$HitboxArea.set_deferred("monitoring", is_active)
	$HitboxArea.set_deferred("monitorable", is_active)
	set_process(!is_active)
	
func _process(delta):
	if regeneration_time == 0:
		set_alive(true)
		return
		
	set_health(current_health + delta / regeneration_time)
