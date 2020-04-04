extends Node

const PRICE_FOR_ALL_ITEMS_IN_SHOP = 200

var shop_menu = null setget set_shop_menu, get_shop_menu


func set_shop_menu(var value):
	if shop_menu != null:
		_push_double_set_warning("shop_menu", shop_menu.name, value.name)
	shop_menu = value


func get_shop_menu():
	if shop_menu == null:
		_push_missing_ref_warning("shop_menu")
	return shop_menu


func _push_double_set_warning(var var_name, var old_name, var new_name):
	push_warning("Globals: Reference to " + var_name + " set to "
		+ new_name + " while already assigned to " + old_name)


func _push_missing_ref_warning(var var_name):
	push_warning("Globals: Reference to " + var_name + "was requested but never set.")
