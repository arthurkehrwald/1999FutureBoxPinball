extends Sprite3D

var item_01_texture = preload("res://HUD/shop_item_01.png")
var item_02_texture = preload("res://HUD/shop_item_02.png")
var item_03_texture = preload("res://HUD/shop_item_03.png")

var selected_item = 1

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _process(delta):
	var previously_selected = selected_item
	if Input.is_action_just_pressed("flipper_left"):
		selected_item -= 1
		if selected_item < 1:
			selected_item = 3
	if Input.is_action_just_pressed("flipper_right"):
		selected_item += 1
		if selected_item > 3:
			selected_item = 1
			
	if previously_selected != selected_item:
		match selected_item:
			1:
				texture = item_01_texture
			2:
				texture = item_02_texture
			3:
				texture = item_03_texture

func _on_GameState_global_reset():
	texture = null
