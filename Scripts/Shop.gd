extends Area

func _ready():
	set_process(false)
	

func _process(delta):
	if Input.is_action_pressed("shop"):
		get_tree().set_paused(true)


func _on_Shop_body_entered(body):
	set_process(true)


func _on_Shop_body_exited(body):
	set_process(false) 
