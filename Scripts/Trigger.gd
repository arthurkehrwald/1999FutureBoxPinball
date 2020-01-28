extends Area

export var triggered_color = Color()
export var triggered_time = 1.0
export var money_value = 150

var default_color = Color()
var unique_material = Material
var can_be_triggered = true

signal hit
signal reset

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	default_color = $MeshInstance.get_surface_material(0).albedo_color
	unique_material = $MeshInstance.get_surface_material(0).duplicate()
	$MeshInstance.set_material_override(unique_material)
	
func _on_Trigger_body_entered(body):
	if can_be_triggered and body.name == "Ball":
		$MeshInstance.get_material_override().albedo_color = triggered_color
		can_be_triggered = false
		$ResetTimer.start()
		emit_signal("hit")
		GameState.set_player_money(GameState.player_money + money_value)

func _on_ResetTimer_timeout():
	$ResetTimer.stop()
	$MeshInstance.get_material_override().albedo_color = default_color
	can_be_triggered = true
	emit_signal("reset")
		
func _on_MultiTrigger_all_hit(all_hit_color):
	$MeshInstance.get_material_override().albedo_color = all_hit_color
	$ResetTimer.stop()
		
func _on_MultiTrigger_all_reset():
	$MeshInstance.get_material_override().albedo_color = default_color
	can_be_triggered = true
	
func _on_GameState_global_reset(_is_init):
	unique_material = $MeshInstance.get_surface_material(0).duplicate()
	$MeshInstance.set_material_override(unique_material)
