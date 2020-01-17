extends PathFollow

signal angle_changed(angle)

var looping_body = null
var speed = 0
var current_pos = Vector3(0, 0, 0)
var prev_pos = Vector3(0, 0, 0)
var curve
var timer
var test_point1
var test_point2

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	set_unit_offset(0.0)
	set_process(false)
	curve = get_node("../").get_curve()
	timer = get_node("../").get_node("Timer")
	test_point1 = get_node("../").get_node("TestPoint1")
	test_point2 = get_node("../").get_node("TestPoint2")
	
	
func _on_Area_body_entered(body):
	looping_body = body
	speed = body.get_linear_velocity().length() * .8
	body.set_visible(false)
	body.set_locked(true)
	body.teleport(get_node("../Exit").get_global_transform().origin, false, Vector3(0, 0, 0))
	$BallReplica.set_visible(true)
	current_pos = $BallReplica.get_global_transform().origin
	prev_pos = current_pos - $BallReplica.get_global_transform().basis.z.normalized() *.1
	set_process(true)
	timer.start()
	
func _process(delta):
		
	#                 X(current_pos)
	#                /|
	#               / |
	#              /  |
	#             /   |
	#            /    |
	# (prev_pos)X-----X (pos_alpha)

	var pos_alpha = Vector3(current_pos.x, prev_pos.y, current_pos.x)
	var prev_to_alpha = pos_alpha - prev_pos
	var prev_to_current = current_pos - prev_pos
	var incline = rad2deg(prev_to_current.normalized().angle_to(prev_to_alpha.normalized()))
	#if incline > 90:
		#incline -= (incline - 90) * 2
		
	var vertical_distance = current_pos.y - prev_pos.y
	if vertical_distance == 0:
		incline = 0
	else:	
		incline = rad2deg(atan(prev_to_alpha.length() / (current_pos.y - prev_pos.y)))
		

	emit_signal("angle_changed", incline)
	
	#speed -= (incline / 90) * .1
#	if get_unit_offset() != 1:
#		set_offset(get_offset() + speed * .4 * delta)
#	else:
#		if looping_body != null:
#			looping_body.set_locked(false)
#			looping_body.apply_central_impulse(-get_node("../Exit").get_global_transform().basis.z.normalized() * speed)
#			looping_body.set_visible(true)
#		$BallReplica.set_visible(false)
		#set_process(false)
		
func _on_GameState_global_reset():
	set_process(false)
	set_unit_offset(0.0)
	$BallReplica.set_visible(false)
	if looping_body != null:
		looping_body.set_visible(true)
	looping_body = null
	speed = 0
	current_pos = Vector3(0, 0, 0)
	prev_pos = Vector3(0, 0, 0)


func _on_Timer_timeout():
	prev_pos = current_pos
	current_pos = $BallReplica.get_global_transform().origin
	print(current_pos)
	
	var incline = 0.0
	var point_progress = curve.get_point_count()  * get_unit_offset()
	if point_progress > .2:
		var last_point_crossed = int(point_progress)
		var progress_to_next_point = point_progress - last_point_crossed	
		current_pos = curve.interpolate(last_point_crossed, progress_to_next_point)

		var prev_point_progress = point_progress - .1
		var prev_last_point_crossed = max(int(prev_point_progress), 0)
		var prev_progress_to_next_point = prev_point_progress - prev_last_point_crossed
		prev_pos = curve.interpolate(prev_last_point_crossed, prev_progress_to_next_point)
		var test_point_1_transform = test_point1.get_global_transform()
		test_point_1_transform.origin = prev_pos
		test_point1.set_global_transform(test_point_1_transform)
		var test_point_2_transform = test_point2.get_global_transform()
		test_point_2_transform.origin = prev_pos
		test_point2.set_global_transform(test_point_2_transform)

		var vertical_dist = current_pos.y - prev_pos.y
		var point_alpha = Vector3(current_pos.x, prev_pos.y, current_pos.z)
		var horizontal_dist = prev_pos.distance_to(point_alpha)
		if horizontal_dist != 0:
			incline = rad2deg(atan(vertical_dist / horizontal_dist))
	print(incline)
	print("")
	emit_signal("angle_changed", incline)
