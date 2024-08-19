extends Node

export(Color) var normal_color = Color(0, 1, 0.81, 1)
export(Color) var critical_color = Color(.97, .04, .40, 1)

func _ready() -> void:
	if Globals.player_ship != null:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
	else:
		push_warning("[CriticalHealthColorSwapper] can't find player. Will not work.")

func on_PlayerShip_health_changed(new_health: float, old_health: float, max_health: float) -> void:
	var is_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	if is_hp_critical:
		set_parent_color(critical_color)
	else:
		set_parent_color(normal_color)

func set_parent_color(color: Color) -> void:
	var parent = get_parent()
	if (parent != null and parent is Control):
		parent = parent as Control
		parent.modulate = color
	
