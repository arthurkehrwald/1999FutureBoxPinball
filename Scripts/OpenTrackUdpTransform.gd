extends Spatial

const DEBUG_MSG = "opentrack:\nX %.4f\nY %.4f\nZ %.4f\nPITCH %.4f\nYAW %.4f\nROLL %.4f"
const PACKET_SIZE_ERROR_MSG = "[OpenTrackUdpTransform] Expected UDP packet size: 48 bytes." \
		+ " Received packet size: %s bytes. Connection will be closed."

export var apply_position := true
export var apply_rotation := true
export var debug_label_path := NodePath()
export var write_debug_output := true

var port = 4242
var udp = PacketPeerUDP.new()
var stream_buffer = StreamPeerBuffer.new()

onready var debug_label := get_node(debug_label_path) as Label

func _ready():
	stream_buffer.set_big_endian(false)
	var err = udp.listen(port)
	if err == OK:
		print ("Listening for opentrack input on port: " + str(port))
	else:
		print ("Listening for opentrack failed.")


func _process(_delta):
	if not udp.is_listening():
		return

	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var success = parse_open_track_packet(packet)
		if !success:
			udp.close()
			break


func parse_open_track_packet(packet) -> bool:
	if packet.size() != 6 * 8:
		push_error(PACKET_SIZE_ERROR_MSG % packet.size())
		return false
	
	var values = []
	for i in range(0, 6 * 8, 8):
		stream_buffer.set_data_array(packet.subarray(i, i + 7))
		values.append(stream_buffer.get_double())
	
	var x = values[0]
	var y = values[1]
	var z = values[2]
	var yaw = values[3]
	var pitch = values[4]
	var roll = values[5]
	
	if write_debug_output:
		debug_label.text = DEBUG_MSG % [x, y, z, pitch, yaw, roll]
	
	if apply_rotation:
		transform.basis = Basis(Vector3(deg2rad(-pitch), deg2rad(yaw), deg2rad(-roll)))
	
	if apply_position:
		transform.origin = Vector3(x, y, z)
	
	return true
