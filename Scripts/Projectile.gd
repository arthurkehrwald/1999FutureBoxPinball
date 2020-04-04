class_name Projectile
extends RigidBody
# Notifies bodies and areas when its area hits them and calls virtual functions
# that derived classes can implement to respond to the collision. Abstract base 
# class for 'Missile.gd' and 'Roller.gd'. 

onready var _hitreg_area = get_node("HitregArea")
onready var _omni_light = get_node("OmniLight")

func _ready():
	_hitreg_area.connect("area_entered", self, "_on_HitregArea_area_entered")
	_hitreg_area.connect("body_entered", self, "_on_HitregArea_body_entered")


func _on_HitregArea_area_entered(_area):
	pass


func _on_HitregArea_body_entered(_body):
	pass
