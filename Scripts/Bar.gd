extends TextureProgress

func _on_value_changed(new_value, new_max_value):
	max_value = new_max_value
	value = new_value
