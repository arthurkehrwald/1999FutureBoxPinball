extends Node

var port = 4242
var udp = PacketPeerUDP.new()
var stream_buffer = StreamPeerBuffer.new()
var newest_packet = null

func _ready():
	stream_buffer.set_big_endian(false)
	var err = udp.listen(port)
	if (err != OK):
		print ("listen Failed")
	else:
		print ("listening on port "+str(port))
	set_process(true)


func _process(delta):
	if (not udp.is_listening()):
		return

	while(udp.get_available_packet_count() > 0):
		newest_packet = udp.get_packet()


func print_newest_packet():
	if !newest_packet:
		return
	var output = ""
	for i in range(0, newest_packet.size() - 7, 8):
		stream_buffer.set_data_array(newest_packet.subarray(i, i + 7))
		output += str(stream_buffer.get_double()) + ","
	print(output)
