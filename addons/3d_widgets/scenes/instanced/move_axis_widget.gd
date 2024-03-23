extends Spatial
tool 

export (Vector3) var size setget set_size

func set_size(new_size:Vector3)->void :
	if size != new_size:
		size = new_size
		if is_inside_tree():
			update()

func _enter_tree()->void :
	update()

func update()->void :
	var local_size = (size * 0.5) + Vector3.ONE

	get_node("AxisX+/ObjectProjector").transform.origin = Vector3(local_size.x, 0, 0)
	get_node("AxisX-/ObjectProjector").transform.origin = Vector3( - local_size.x, 0, 0)

	get_node("AxisY+/ObjectProjector").transform.origin = Vector3(local_size.y, 0, 0)
	get_node("AxisY-/ObjectProjector").transform.origin = Vector3( - local_size.y, 0, 0)

	get_node("AxisZ+/ObjectProjector").transform.origin = Vector3(local_size.z, 0, 0)
	get_node("AxisZ-/ObjectProjector").transform.origin = Vector3( - local_size.z, 0, 0)
