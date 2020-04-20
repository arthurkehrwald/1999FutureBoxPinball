extends "res://Testing/InheritanceTestTop.gd"

func _ready():
	print("mid: ready")

func _overwrite():
	print("mid: overwrite")
	._overwrite()
