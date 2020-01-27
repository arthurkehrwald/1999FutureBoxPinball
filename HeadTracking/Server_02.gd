extends Node
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var IP_CLIENT 
var PORT_CLIENT
var IP_SERVER = "127.0.0.1" #127.0.0.1 is the local IP-Adress
var PORT_SERVER = 5550
var socketUDP = PacketPeerUDP.new()


func _ready():
	start_server()

func _process(delta):
	if socketUDP.get_available_packet_count() > 0:
		var array_bytes = socketUDP.get_packet()
		var stream = StreamPeerBuffer.new()
		stream.set_data_array(array_bytes)
		print(stream.get_double())
		print(stream.get_double())
		print(stream.get_double())
		print(stream.get_double())
		print(stream.get_double())
		print(stream.get_double())
		print(stream.get_32())
		print("----------")
func start_server():
	if(socketUDP.listen(PORT_SERVER) != OK):
		printt("error")
	else:
		printt("listening to port: " + str(PORT_SERVER))

func _exit_tree():
	print("exiting")
	socketUDP.close()
#C:\Users\marco\Desktop\Godot_v3.2-beta5_win64.exe -s C:\Users\marco\Desktop\testThing\Scene\Server.gd
