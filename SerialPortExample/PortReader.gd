extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

#helper node
onready var com=$Com 
#use it as node since script alone won't have the editor help

var port
var output
var intData = 0
var floatData = 0.0
var normalizedPlungerData = 1234.0
var data = ""
var raw = 0


#signal buttonR_signal
#signal buttonL_signal
signal button_signal
signal plunger_signal

func _ready():
	#emit_signal("test_signal")
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
			raw = PORT.read(true)
			if raw != 10 :
				if raw == 76:
					emit_signal("button_signal", "left")
					print("L")
				if raw == 82:
					emit_signal("button_signal", "right")
					print("R")
				else:
					output = PoolByteArray([raw]).get_string_from_ascii()
					data += output
		if raw < 58: 
			floatData = float(data)
			data = ""
			if floatData > 20 && intData < 200:
				normalizedPlungerData = (float((floatData - 21)/(199-20)))
				emit_signal("plunger_signal", normalizedPlungerData)
		#	print(normalizedData)

