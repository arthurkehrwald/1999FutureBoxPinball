class_name RotationStabiliser
extends Spatial
# Keeps a node's rotation aligned with the global coordinate system,
# regardless of the parent's rotation, while still allowing the node
# to move and scale with its parent.


func _process(_delta):
	look_at(get_global_transform().origin + Vector3.RIGHT, Vector3.UP)
