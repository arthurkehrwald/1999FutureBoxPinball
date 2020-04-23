extends OmniLight

onready var animation_player = get_node("AnimationPlayer")


func _ready():
	animation_player.connect("animation_finished", self, "on_animation_finished")


func on_animation_finished(_anim_name):
	queue_free()
