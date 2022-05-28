class_name BumperCluster
extends Spatial

signal bumped(bumper_cluster, bumper, bumped_body)

export var TIME_LIMIT = 0.0
export var BUMP_LIMIT = 0
export var DISABLED_DURATION = 3.0
export(float, 0.0, 180.0) var MAX_AUTO_AIM_ANGLE 

var bumpers = []
var bump_count = 0
var rng =  RandomNumberGenerator.new()

onready var disable_timer = get_node("DisableTimer")
onready var enable_timer = get_node("EnableTimer")


func _ready():
	rng.randomize()
	disable_timer.connect("timeout", self, "toggle_bumpers", [false])
	enable_timer.connect("timeout", self, "toggle_bumpers", [true])
	for child in get_children():
		if child is Bumper:
			bumpers.push_back(child)
			child.connect("bumpable_body_entered", self, "on_Bumper_bumpable_body_entered")
			child.connect("bumped", self, "on_Bumper_bumped")
			child.is_controlled_by_bumper_cluster = true


func toggle_bumpers(value):
	for bumper in bumpers:
		bumper.set_deferred("monitoring", value)
	disable_timer.stop()
	bump_count = 0
	if not value:
		enable_timer.start(DISABLED_DURATION)


func on_Bumper_bumpable_body_entered(bumper, bumpable_body):
	var bumpable_body_pos = bumpable_body.global_transform.origin
	var bumper_pos = bumper.global_transform.origin	
	var dir_from_bumper_to_bumpable_body = (bumpable_body_pos - bumper_pos).normalized()
	var eligible_target_bumpers = []
	for other_bumper in bumpers:
		if other_bumper == bumper:
			continue
		var other_bumper_pos = other_bumper.global_transform.origin
		var dir_from_bumper_to_other_bumper = (other_bumper_pos - bumper_pos).normalized()
		var ang = dir_from_bumper_to_bumpable_body.angle_to(dir_from_bumper_to_other_bumper)
		ang = rad2deg(ang)
		if ang < MAX_AUTO_AIM_ANGLE:
			eligible_target_bumpers.push_back(other_bumper)
	if eligible_target_bumpers.empty():
		bumper.bump_in_dir(bumpable_body, dir_from_bumper_to_bumpable_body)
		return
	var target_bumper = eligible_target_bumpers[rng.randi() % eligible_target_bumpers.size()]
	bumper.bump_towards_pos(bumpable_body, target_bumper.global_transform.origin)


func on_Bumper_bumped(bumper, bumped_body):
	if TIME_LIMIT > 0 and disable_timer.is_stopped():
		disable_timer.start(TIME_LIMIT)
	bump_count += 1
	print("bump count: " + str(bump_count))
	if BUMP_LIMIT > 0 and bump_count >= BUMP_LIMIT:
		toggle_bumpers(false)
	emit_signal("bumped", self, bumper, bumped_body)
