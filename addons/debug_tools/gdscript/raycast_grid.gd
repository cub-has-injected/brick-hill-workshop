"\n2D grid of 3D RayCast nodes for debugging collision\n"

class_name RaycastGrid
extends Spatial
tool 

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("raycast_grid_child"):
			remove_child(child)
			child.queue_free()

	for y in range(0, 20):
		for x in range(0, 20):
			var raycast = RayCast.new()
			raycast.enabled = true
			raycast.cast_to = Vector3.DOWN * 10
			raycast.set_meta("raycast_grid_child", true)
			add_child(raycast)
			raycast.transform.origin = Vector3(x * 0.5, 0, y * 0.5)
