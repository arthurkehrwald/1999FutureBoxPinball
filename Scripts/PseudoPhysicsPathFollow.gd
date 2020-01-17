extends PathFollow

signal angle_changed(angle)

var looping_body = null
var speed = 0
var current_pos = Vector3(0, 0, 0)
var prev_pos = Vector3(0, 0, 0)
var curve
var timer

func _enter_tree():
	GameState.connect("global_reset", self, "_on_GameState_global_reset")

func _ready():
	set_unit_offset(0.0)
	set_process(true)
	curve = get_node("../").get_curve()
	timer = get_node("../").get_node("Timer")
	
func _on_Area_body_entered(body):
	looping_body = body
	speed = body.get_linear_velocity().length()
	body.set_visible(false)
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
	if incline > 90:
		incline -= (incline - 90) *2
	
#	incline = curve.get_point_tilt(curve.get_point_count() * get_unit_offset())
#
#	incline = curve.interpolate_baked_up_vector(get_offset(), true) #kinda worked
#	#emit_signal("angle_changed", rad2deg(incline.angle_to(Vector3(incline.x, 0, incline.z))))
#
#	var point_behind
#	var point_ahead	
#	if get_unit_offset() > .02:
#		point_behind = curve.get_point_position(curve.get_point_count() * get_unit_offset() - .01)
#	else:
#		point_behind = curve.get_point_position(0)
#	if get_unit_offset() < .98:
#		point_ahead = curve.get_point_position(curve.get_point_count() * get_unit_offset() + .01)
#	else:
#		point_ahead = curve.get_point_position(curve.get_point_count() - 1)
#	var point_alpha = Vector3(point_ahead.x, point_behind.y, point_behind.z)
#	var behind_alpha = (point_alpha - point_behind).normalized()
#	var behind_ahead = (point_ahead - point_behind).normalized()
#	incline = point_ahead.y - point_behind.y
#
#	#var progress = get_offset() / curve.get_baked_length()
#	var point_progress = curve.get_point_count()  * get_unit_offset()
#	if (point_progress > .2):
#		var last_point_crossed = int(point_progress)
#		var progress_to_next_point = point_progress - last_point_crossed	
#		current_pos = curve.interpolate(last_point_crossed, progress_to_next_point)
#
#		var prev_point_progress = point_progress - .1
#		var prev_last_point_crossed = max(int(prev_point_progress), 0)
#		var prev_progress_to_next_point = prev_point_progress - prev_last_point_crossed
#		prev_pos = curve.interpolate(prev_last_point_crossed, prev_progress_to_next_point)
#
#		point_alpha = Vector3(prev_pos.x, current_pos.y, current_pos.z)
#		var prev_alpha = (point_alpha - prev_pos).normalized()
#		var prev_current = (current_pos - prev_pos).normalized()
#		incline = rad2deg(prev_current.angle_to(prev_alpha))
#	else:
#		incline = 0.0
	
	
	emit_signal("angle_changed", incline)
	
	speed -= (incline / 90) * .05
	if get_unit_offset() != 1:
		set_offset(get_offset() + speed * delta)
	else:
		if looping_body != null:
			looping_body.teleport(current_pos, false, -get_node("../Exit").get_global_transform().basis.z.normalized() * speed)
			looping_body.set_visible(true)
		$BallReplica.set_visible(false)
		set_process(false)
		
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
	#print(current_pos)
