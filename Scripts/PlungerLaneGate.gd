extends Spatial

var is_open = false
var pinballs_in_plunger_lane = 0

onready var animation_player = get_node("AnimationPlayer")
onready var area = get_node("Area")


func _ready():
	area.connect("body_entered", self, "on_Area_body_entered")
	area.connect("body_exited", self, "on_Area_body_exited")


func on_Area_body_entered(body):
	if not body.is_in_group("pinballs"):
		return
	pinballs_in_plunger_lane += 1
	if not is_open:
		animation_player.play("plunger_lane_gate_open")
		is_open = true


func on_Area_body_exited(body):
	if not body.is_in_group("pinballs"):
		return
	pinballs_in_plunger_lane -= 1
	if is_open and pinballs_in_plunger_lane <= 0:
		animation_player.play("plunger_lane_gate_close")
		is_open = false
