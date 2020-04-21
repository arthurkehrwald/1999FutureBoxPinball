extends Spatial

const BALL_SCENE = preload("res://Scenes/Pinball.tscn")
const EXPLOSION_SCENE = preload("res://Scenes/Particles Explosion_01.tscn")

var accessible_balls = 0


func _ready():
	spawn_ball()
	


func spawn_ball():
	accessible_balls += 1
	var ball_instance = BALL_SCENE.instance()
	call_deferred("add_child", ball_instance)
	ball_instance.connect("accessibility_changed", self, "on_Ball_accessibility_changed")
	var explosion_instance = EXPLOSION_SCENE.instance()
	explosion_instance.set_global_transform(get_global_transform())
	get_node("/root").add_child(explosion_instance)
	explosion_instance.get_node("Billboard Particles").emitting = true
	explosion_instance.get_node("Billboard Particles2").emitting = true
	explosion_instance.get_node("Data Shit").emitting = true
	explosion_instance.get_node("Data Shit2").emitting = true
	explosion_instance.get_node("Data Shit3").emitting = true
	explosion_instance.get_node("Strudel").emitting = true


func on_Ball_accessibility_changed(value):
	accessible_balls += 1 if value else -1
	print("accessible balls: ", accessible_balls)
	if accessible_balls < 1:
		spawn_ball()

		
