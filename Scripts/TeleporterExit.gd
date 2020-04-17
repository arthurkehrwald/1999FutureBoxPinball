extends Spatial


func _enter_tree():
	Globals.teleporter_exits.push_back(self)
