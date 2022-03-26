extends Spatial

const DEBUG_MSG = "Tracker:\nX %.4f\nY %.4f\nZ %.4f\nPITCH %.4f\nYAW %.4f\nROLL %.4f"
const PACKET_SIZE_ERROR_MSG = "[UdpHeadTrackingReceiver] Expected UDP packet" \
		+ " size: 12 bytes (kinect console bridge) or 48 bytes (opentrack)." \
		+ " Received packet size: %s bytes. Connection will be closed."

export var apply_position := true
export var apply_rotation := true
export var debug_label_path := NodePath()
export var write_debug_output := true
export var port := 4242

var udp = PacketPeerUDP.new()
var stream_buffer = StreamPeerBuffer.new()

onready var debug_label := get_node(debug_label_path) as Label

func _ready():
	stream_buffer.set_big_endian(false)
	var err = udp.listen(port)
	if err == OK:
		print ("Listening for head tracking input on port: " + str(port))
	else:
		print ("Listening for head tracking input failed.")


func _process(_delta):
	if not udp.is_listening():
		return

	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var track_data = null
		if (packet.size() == 6 * 8):
			track_data = parse_opentrack_packet(packet)
		elif (packet.size() == 3 * 4):
			track_data = parse_kinect_packet(packet)
		else:
			push_error(PACKET_SIZE_ERROR_MSG % packet.size())
			udp.close()
			return
		
		apply_head_tracking_data((track_data))
		write_debug_output(track_data)


func parse_opentrack_packet(packet) -> HeadTrackingData:
	var values = []
	
	for i in range(0, 6 * 8, 8):
		stream_buffer.set_data_array(packet.subarray(i, i + 7))
		values.append(stream_buffer.get_double())
	
	var data = HeadTrackingData.new()
	data.x = values[0] / 10
	data.y = values[1] / 10
	data.z = values[2] / 10
	data.yaw = values[3]
	data.pitch = values[4]
	data.roll = values[5]
	return data;


func parse_kinect_packet(packet) -> HeadTrackingData:
	var values = []
	
	for i in range(0, 3 * 4, 4):
		stream_buffer.set_data_array(packet.subarray(i, i + 3))
		values.append(stream_buffer.get_float())
	
	var data = HeadTrackingData.new()
	data.x = values[0]
	data.y = values[1]
	data.z = values[2]
	return data;


func apply_head_tracking_data(data):
	if data.isPosDefined() && apply_position:
		transform.origin = Vector3(data.x, data.y, data.z)
		
	if data.isRotDefined() && apply_rotation:
		transform.basis = Basis(Vector3(deg2rad(data.pitch),
				deg2rad(data.yaw),
				deg2rad(data.roll)))


func write_debug_output(data):
	if write_debug_output:
		debug_label.text = DEBUG_MSG % [data.x, data.y, data.z,
		data.pitch, data.yaw, data.roll]


class HeadTrackingData:
	var x : float
	var y : float
	var z : float
	var yaw : float
	var pitch : float
	var roll : float
	
	func isPosDefined() -> bool:
		return x != 0 || y != 0 || z != 0
		
	func isRotDefined() -> bool:
		return yaw != 0 || pitch != 0 || roll != 0
