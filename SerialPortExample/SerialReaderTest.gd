extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

#helper node
onready var com=$Com 
#use it as node since script alone won't have the editor help

var port
var data
var intData

func _ready():
	PORT.close()
	for index in PORT.list_ports():
		if index == "COM7":
			port = index

	PORT.open(port, 9600,1000)

#_physics_process may lag with lots of characters, but is the simplest way
#for best speed, you can use a thread
#do not use _process due to fps being too high
func _physics_process(delta): 
	if PORT.get_available()>0:
		for i in range(PORT.get_available()):
			print(PORT.read())
			#data = PORT.read()
			#intData = int(data);
