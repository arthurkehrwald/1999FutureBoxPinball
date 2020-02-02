extends Area

signal exploded

enum explosion_type {BOMB, MISSILE}
export(explosion_type) var type = explosion_type.BOMB
var method_to_call = ""


func _ready():
	match type:
		explosion_type.BOMB:
			method_to_call = "_on_Bomb_explosion_hit"
		explosion_type.MISSILE:
			method_to_call = "_on_Missile_explosion_hit"

func explode():
	set_deferred("monitoring", true)
	set_deferred("monitorable", false)
	$Timer.start()

func _on_Explosion_body_entered(body):
	print("Explosion hit: ", body.owner.name, " at pos: ", body.get_global_transform().origin)
	if body.has_method(method_to_call):
		body.call(method_to_call, get_global_transform().origin)
	elif body.owner.has_method(method_to_call):
		body.owner.call(method_to_call, get_global_transform().origin)
		
func _on_Timer_timeout():
	emit_signal("exploded")
	queue_free()
