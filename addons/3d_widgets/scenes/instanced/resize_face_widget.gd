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
	var local_size = size * (Vector3.ONE * 0.5) + Vector3.ONE

	get_node("AxisX+/ObjectProjector").transform.origin.x = local_size.x
	get_node("AxisX-/ObjectProjector").transform.origin.x = - local_size.x

	get_node("AxisY+/ObjectProjector").transform.origin.x = local_size.y
	get_node("AxisY-/ObjectProjector").transform.origin.x = - local_size.y

	get_node("AxisZ+/ObjectProjector").transform.origin.x = local_size.z
	get_node("AxisZ-/ObjectProjector").transform.origin.x = - local_size.z
