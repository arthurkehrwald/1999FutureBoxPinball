extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

#helper node
onready var com=$Com 
#use it as node since script alone won't have the editor help

var port
var data

func _ready():
	set_physics_process(false)
	PORT.close()
	PORT.open("COM7",9600,1000)
	set_physics_process(true)
#_physics_process may lag with lots of characters, but is the simplest way
#for best speed, you can use a thread
#do not use _process due to fps being too high
func _physics_process(delta): 
	if PORT.get_available()>0:
		#for i in range(PORT.get_available()):
		data = PORT.read()
		#$RichTextLabel.add_text(String(int(data)) + "\n")
		if(data!= "0"):
			$Sprite.set_position(Vector2(data,data) * 10)

