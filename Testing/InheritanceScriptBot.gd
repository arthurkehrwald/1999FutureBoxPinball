extends "res://Testing/InheritanceScriptMid.gd"

func _ready():
	print("bot: ready")

func _overwrite():
	print("bot: overwrite")
	._overwrite()
