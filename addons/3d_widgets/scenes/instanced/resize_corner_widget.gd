extends Spatial
tool 

export (Vector3) var size: = Vector3.ONE setget set_size

func set_size(new_size:Vector3)->void :
	if size != new_size:
		size = new_size
		if is_inside_tree():
			update()

func _enter_tree()->void :
	update()

func update()->void :
	var local_size = size * (Vector3.ONE * 0.5) + (Vector3.ONE * 0.5)

	get_node("AxisX+Y+Z+/ObjectProjector").transform.origin = local_size * Vector3(1, 1, 1)
	get_node("AxisX-Y-Z-/ObjectProjector").transform.origin = local_size * Vector3( - 1, - 1, - 1)

	get_node("AxisX-Y-Z+/ObjectProjector").transform.origin = local_size * Vector3( - 1, - 1, 1)
	get_node("AxisX+Y+Z-/ObjectProjector").transform.origin = local_size * Vector3(1, 1, - 1)

	get_node("AxisX-Y+Z-/ObjectProjector").transform.origin = local_size * Vector3( - 1, 1, - 1)
	get_node("AxisX+Y-Z+/ObjectProjector").transform.origin = local_size * Vector3(1, - 1, 1)

	get_node("AxisX+Y-Z-/ObjectProjector").transform.origin = local_size * Vector3(1, - 1, - 1)
	get_node("AxisX-Y+Z+/ObjectProjector").transform.origin = local_size * Vector3( - 1, 1, 1)
