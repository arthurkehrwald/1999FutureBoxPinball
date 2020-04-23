extends OmniLight

signal finished

onready var animation_player = get_node("AnimationPlayer")


func _ready():
	animation_player.connect("animation_finished", self, "on_animation_finished")


func activate():
	animation_player.play("flashing_light")


func on_animation_finished(_anim_name):
	emit_signal("finished")
