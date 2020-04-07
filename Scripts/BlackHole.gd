extends Spatial

export var appear_time = 5
export  var expand_scale_factor = 20
export var expand_time = 3

var rng = RandomNumberGenerator.new()
var base_scale_vector = Vector3(1, 1, 1)
var current_scale_vector = Vector3(1, 1, 1)
var scale_interp_value = 1

func _enter_tree():
	GameState.connect("state_changed", self, "_on_GameState_changed")

func _ready():
	base_scale_vector = $GravitationalField/MeshInstance.get_transform().basis.get_scale()
	current_scale_vector = base_scale_vector
	rng.randomize()
	set_process(false)
	
func _process(_delta):
	if $AnimationPlayer.is_playing():
		current_scale_vector = $GravitationalField/MeshInstance.get_transform().basis.get_scale()
	$GravitationalField/MeshInstance.set_transform(Transform.IDENTITY.scaled(current_scale_vector * rng.randfn(1, .1)))
	
func _on_GameState_changed(new_stage, is_debug_skip):
	if is_debug_skip or new_stage == GameState.PREGAME:
		set_is_active(false)

func _on_NomArea_body_entered(body):
	if body.is_in_group("Pinballs"):
		body._on_destroyed()
	elif body.is_in_group("Bombs"):
		body.queue_free()

func set_is_active(is_active):
	#print("Black Hole: active - ", is_active)
	if is_active:
		Announcer.say("black_hoe", true)
	set_visible(is_active)
	#set_process(is_active)
	$GravitationalField/CollisionShape.set_deferred("disabled", !is_active)
	$GravitationalField/NomArea/CollisionShape.set_deferred("disabled", !is_active)
	if is_active:
		$AnimationPlayer.play("black_hole_appear_anim")

func expand():
	print("Black Hole: expanding")
	$AnimationPlayer.play("black_hole_expand_anim")
	
	yield($AnimationPlayer, "animation_finished")
	
	GameState.on_BlackHole_fully_expanded()
	$AnimationPlayer.play("black_hole_fade")
	
	yield($AnimationPlayer, "animation_finished")
	
	set_is_active(false)


func _on_Boss_black_hole_health_threshold_reached():
	print("Black Hole: activation boss health threshold reached")
	set_is_active(true)


func _on_Boss_ECLIPSE_health_threshold_reached():
	expand()
