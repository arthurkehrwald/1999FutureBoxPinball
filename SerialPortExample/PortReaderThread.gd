extends Control

var thread = Thread.new()

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

#helper node
onready var com=$Com 
#use it as node since script alone won't have the editor help

var port
var portNumber = "COM7"
var number
var output
var floatData = 0.0;
var data = ""

func _ready():
	_start_thread()

func _open_port(portNumber):
	set_physics_process(false)
	PORT.close()
	PORT.open(portNumber, 9600, 1000)
	set_physics_process(true)
	_read_port()
	

func _start_thread():
	if thread.is_active():
		return
	thread.start(self, "_open_port", portNumber)

#func _ready():
#	set_physics_process(false)
#	PORT.close()
#	PORT.open("COM7", 9600, 1000)
#	set_physics_process(true)
func _read_port():
	print("thread running")
	if PORT.get_available()>0:
		for i in range(PORT.get_available()):
			var raw = PORT.read(true)
			if(raw != 10):
				output = PoolByteArray([raw]).get_string_from_ascii()
				data += output
		floatData = float(data)
		data = ""
		print(floatData)
	call_deferred("read_port_done")

func _read_port_done():
	thread.wait_to_finish()
	print("stop thread")
