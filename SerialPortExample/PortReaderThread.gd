extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

#helper node
onready var com=$Com 
#use it as node since script alone won't have the editor help

var port
var number
var output
var intData = 0;
var data = ""

func _ready():
	set_physics_process(false)
	PORT.close()
	PORT.open("COM7", 9600, 1000)
	set_physics_process(true)

#_physics_process may lag with lots of characters, but is the simplest way
#for best speed, you can use a thread
#do not use _process due to fps being too high
func _physics_process(delta): 
	#print(PORT.get_available())
	if PORT.get_available()>0:
		for i in range(PORT.get_available()):
			var raw = PORT.read(true)
			if(raw != 10):
				output = PoolByteArray([raw]).get_string_from_ascii()
				data += output
		intData = int(data)
		data = ""
		if(intData > 20 && intData < 300):
			$Sprite.set_position(Vector2(intData, intData))
