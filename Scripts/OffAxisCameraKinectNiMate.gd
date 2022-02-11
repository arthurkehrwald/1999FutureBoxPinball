extends Camera

export (int) var PORT = 7000
export (NodePath) var kinect_dummy_path = ""
export (float, 1, 100) var track_scale = 10

var _udp = PacketPeerUDP.new()
var _ser_des = StreamPeerBuffer.new()

var head_dummy = null
onready var kinect_out_label = get_node("KinectOutLabel")

var _table = { "i" : funcref(self, "_read_int"),
			   "f" : funcref(self, "_read_float"),
			   "s" : funcref(self, "_read_string"),
			   "b" : funcref(self, "_read_blob"),
			   "d" : funcref(self, "_read_double") }


func _ready():
	if !current or !has_node(kinect_dummy_path):
		set_process(false)
		return
	head_dummy = Spatial.new()
	get_node(kinect_dummy_path).add_child(head_dummy)
	_ser_des.set_big_endian(true)
	_udp.listen(PORT, "127.0.0.1")
	print("Delicode NI mate Tools started listening to OSC on port " + str(PORT))
	set_process(true)


func _process(_delta):
	if not _udp.is_listening():
		printerr("Network disconnected!")
		get_tree().quit()

	while _udp.get_available_packet_count() > 0:
		var data = _udp.get_packet()

		var decoded = _decode_osc(data)
		var ob_name = PoolByteArray(decoded[0]).get_string_from_utf8()

		if ob_name.begins_with("@"):
			# Ignored for now
			pass

		elif ob_name.begins_with("?"):
			# Ignored for now
			pass
			
		elif ob_name != "Head":
			# Ignored for now
			pass

		elif len(decoded) == 3: #one value
			# Ignored for now
			pass
		
		elif len(decoded) == 5: #location
			kinect_out_label.text = "kinect:\n%.4f\n%.4f\n%.4f" % [decoded[2],
					decoded[3], decoded[4]]
			head_dummy.set_translation(Vector3(decoded[2], decoded[3], decoded[4]))
			set_global_transform(Transform(get_global_transform().basis, head_dummy.get_global_transform().origin))

		elif len(decoded) == 6: #quaternion
			head_dummy.set_transform(Transform(Quat(decoded[6], decoded[7], decoded[8], -decoded[5])))
			set_global_transform(Transform(get_global_transform().basis, head_dummy.get_global_transform().origin))

		elif len(decoded) == 9: #location & quaternion
			head_dummy.set_transform(Transform(Quat(decoded[6], decoded[7], decoded[8], -decoded[5]),
												Vector3(decoded[2], decoded[3], decoded[4])))
			set_global_transform(Transform(get_global_transform().basis, head_dummy.get_global_transform().origin))
		
		else:
			printerr("Delicode NI mate Tools error parsing OSC message: " + str(decoded))

	set_frustum_offset(
		Vector2(get_transform().origin.x * -.31,
		get_transform().origin.z * .31)
		)
	set_znear((get_transform().origin.y - 1) * .31)


var _first = null
var _second = null


func _read_byte(data):
	var length = Array(data).find(0)
	var next_data = int(ceil((length + 1) / 4.0) * 4)
	_first = Array(data.subarray(0, length - 1))
	_second = Array(data.subarray(next_data, -1))


func _read_string(_data):
	# Unused for now
	pass


func _read_blob(_data):
	# Unused for now
	pass


func _read_int(data):
	if len(data) < 4:
		printerr("Error: too few bytes for int", data, len(data))
		_first = 0
		_second = Array(data)
	else:
		_ser_des.set_data_array(data.subarray(0, 3))
		_first = _ser_des.get_32()

		if len(data) > 4:
			_second = Array(data.subarray(4, -1))
		else:
			_second = null


func _read_long(_data):
	# Unused for now
	pass


func _read_double(_data):
	# Unused for now
	pass


func _read_float(data):
	if len(data) < 4:
		printerr("Error: too few bytes for float", data, len(data))
		_first = 0.0
		_second = Array(data)
	else:
		_ser_des.set_data_array(data.subarray(0, 3))
		_first = _ser_des.get_float()

		if len(data) > 4:
			_second = Array(data.subarray(4, -1))
		else:
			_second = null


func _decode_osc(data):
	_read_byte(data)
	var address = _first
	var rest = _second

	var decoded = []

	if len(rest) > 0:
		_read_byte(PoolByteArray(rest))
		var typetags = _first
		rest = _second

		decoded.append(address)
		decoded.append(typetags)

		if len(typetags) > 0:
			if char(typetags[0]) == ',':
				for tag in PoolByteArray(typetags).subarray(1, -1):
					_table[char(tag)].call_func(PoolByteArray(rest))
					var value = _first
					rest = _second

					decoded.append(value)
			else:
				printerr("Oops, typetag lacks the magic")

	return decoded
