extends Node

var available = []
var in_use = []
var node_type = ""


func _init(scene, size):
	assert(size >= 1)
	for _index in range(0, size):
		var instance = scene.instance()
		node_type = instance.name
		instance.connect("finished", self, "withdraw")
		available.push_back(instance)


func deploy(pos):
	var node = available.pop_back()
	if node == null:
		node = in_use.pop_front()
		push_warning("Not enough nodes of type " + node_type + "!"
				+ " Had to reuse node that was still in use.")
	else:
		PoolManager.add_child(node)
	in_use.push_back(node)
	node.set_global_transform(Transform(Basis.IDENTITY, pos))
	node.activate()


func withdraw():
	var node = in_use.pop_front()
	assert(node != null)
	PoolManager.remove_child(node)
	available.push_back(node)
