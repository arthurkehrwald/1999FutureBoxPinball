extends StaticBody

onready var collision_mask_when_enabled = collision_mask
onready var collision_layer_when_enabled = collision_layer

func set_enabled(enabled : bool):
	if enabled:
		collision_mask = collision_mask_when_enabled
		collision_layer = collision_layer_when_enabled
	else:
		collision_mask_when_enabled = collision_mask
		collision_layer_when_enabled = collision_layer
		collision_mask = 0
		collision_layer = 0
