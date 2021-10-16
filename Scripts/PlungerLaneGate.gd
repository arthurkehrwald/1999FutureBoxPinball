extends Spatial

var is_open = false
var pinballs_in_plunger_lane_count = 0
var pinballs_in_gate_area_count = 0

onready var animation_player = get_node("AnimationPlayer")
onready var lane_area = get_node("LaneArea")
onready var gate_area = get_node("GateArea")


func _ready():
	lane_area.connect("body_entered", self, "on_LaneArea_body_entered")
	lane_area.connect("body_exited", self, "on_LaneArea_body_exited")
	gate_area.connect("body_entered", self, "on_GateArea_body_entered")
	gate_area.connect("body_exited", self, "on_GateArea_body_exited")


func on_LaneArea_body_entered(body):
	if not body.is_in_group("pinballs"):
		return
	pinballs_in_plunger_lane_count += 1
	update_gate_status()


func on_LaneArea_body_exited(body):
	if not body.is_in_group("pinballs"):
		return
	pinballs_in_plunger_lane_count -= 1
	pinballs_in_plunger_lane_count = max(pinballs_in_plunger_lane_count, 0)
	update_gate_status()


func on_GateArea_body_entered(body):
	if not body.is_in_group("pinballs"):
		return
	pinballs_in_gate_area_count += 1
	update_gate_status()


func on_GateArea_body_exited(body):
	if not body.is_in_group("pinballs"):
		return
	pinballs_in_gate_area_count -= 1
	pinballs_in_gate_area_count = max(pinballs_in_gate_area_count, 0)
	update_gate_status()


func update_gate_status():
	if is_open and pinballs_in_gate_area_count == 0 and pinballs_in_plunger_lane_count == 0:
		animation_player.play("plunger_lane_gate_close")
		is_open = false
	elif not is_open and pinballs_in_plunger_lane_count > 0:
		animation_player.play("plunger_lane_gate_open")
		is_open = true
