class_name Projectile
extends RigidBody
# Notifies bodies and areas when its area hits them and calls virtual functions
# that derived classes can implement to respond to the collision. Abstract base 
# class for 'Missile.gd' and 'Roller.gd'. 


func _on_Area_area_entered(area):
	_notify_hit_node(area)
	_on_hit_area(area)


func _on_Area_body_entered(body):
	_notify_hit_node(body)
	_on_hit_body(body)


func _notify_hit_node(var node):
	if node.has_method("on_hit_by_projectile"):
		node.on_hit_by_projectile()


func _on_hit_area(area):
	pass


func _on_hit_body(body):
	pass
