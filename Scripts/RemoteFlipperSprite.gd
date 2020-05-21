extends Sprite3D

onready var super_glitch_ap = get_node("Viewport/GlitchOverlay/SuperGlitchAnimationPlayer")


func _ready():
	texture = $Viewport.get_texture()
	visible = false
	if Globals.powerup_roulette != null:
		Globals.powerup_roulette.connect("selected_remote", self, "on_PowerupRoulette_selected_remote")
		Globals.powerup_roulette.connect("remote_expired", self, "on_PowerupRoulette_remote_expired")


func on_PowerupRoulette_selected_remote():
	visible = true
	super_glitch_ap.play("super_glitch")
	super_glitch_ap.disconnect("animation_finished", self, "on_SuperGlitchAP_finished")


func on_PowerupRoulette_remote_expired():
	super_glitch_ap.play("super_glitch")
	super_glitch_ap.connect("animation_finished", self, "on_SuperGlitchAP_finished", [], CONNECT_ONESHOT)


func on_SuperGlitchAP_finished(_anim_name):
	visible = false
