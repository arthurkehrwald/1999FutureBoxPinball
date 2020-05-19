extends Control

var is_player_hp_critical = false

onready var anim_player = get_node("AnimationPlayer")
onready var glitch_overlay = get_node_or_null("../GlitchOverlay")


func _enter_tree():
	Globals.warning_hud = self


func _ready():
	if Globals.player_ship == null:
		push_warning("[WarningHUD] can't find player ship. Will not" 
				+ " become show warning when player health critical.")
	else:
		Globals.player_ship.connect("health_changed", self, "on_PlayerShip_health_changed")
	if Globals.powerup_roulette == null:
		push_warning("[WarningHUD] can't find powerup roulette. Will not" 
				+ " disappear when it is active.")
	else:
		Globals.powerup_roulette.connect("visibility_changed", self, "update_visibility")


func on_PlayerShip_health_changed(new_health, old_health, max_health):
	is_player_hp_critical = new_health / max_health * 100 <= Globals.PLAYER_CRITICAL_HEALTH_PERCENT
	update_visibility()


func update_visibility():
	if Globals.powerup_roulette != null and Globals.powerup_roulette.visible:
		visible = false
	else:
		visible = is_player_hp_critical
	if visible:
		anim_player.play("text_appear")
		if glitch_overlay != null:
			glitch_overlay.super_glitch()
