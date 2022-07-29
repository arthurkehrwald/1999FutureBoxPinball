class_name TurretPowerup
extends "res://Scripts/Powerup.gd"

export var path_to_turret : NodePath

onready var turret = get_node(path_to_turret) as PlayerTurret

func _ready():
	turret.connect("is_active_changed", self, "_on_Turret_is_active_changed")

func _on_Turret_is_active_changed(is_turret_active: bool):
	if is_active and !is_turret_active:
		deactivate()

func activate():
	if (is_active):
		return
	.activate()
	turret.set_is_active(true)

func deactivate():
	if (!is_active):
		return
	.deactivate()
	turret.set_is_active(false)
