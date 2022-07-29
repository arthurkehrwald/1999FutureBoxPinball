extends Sprite3D

onready var super_glitch_ap = get_node("Viewport/GlitchOverlay/SuperGlitchAnimationPlayer")

func _ready():
	texture = $Viewport.get_texture()
	visible = false

func set_active(value: bool):
	if value:
		visible = true
		super_glitch_ap.play("super_glitch")
		super_glitch_ap.disconnect("animation_finished", self, "on_SuperGlitchAP_finished")
	else:
		super_glitch_ap.play("super_glitch")
		yield(super_glitch_ap, "animation_finished")
		visible = false
