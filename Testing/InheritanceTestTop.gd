extends Node

func _ready():
	print("top: ready")
	_overwrite()

func _overwrite():
	print("top: overwrite")
