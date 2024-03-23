"\n2D plane composed of Mesh.PRIMITIVE_LINES\n"

class_name GeometryPlane
extends ImmediateGeometry
tool 

export (Vector2) var size: = Vector2(10, 10) setget set_size

func set_size(new_size:Vector2)->void :
	var scope = Profiler.scope(self, "set_size", [new_size])

	new_size = new_size.round()

	if size != new_size:
		size = new_size
		if is_inside_tree():
			rebuild()

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	rebuild()

func rebuild()->void :
	var scope = Profiler.scope(self, "rebuild", [])

	clear()

	begin(Mesh.PRIMITIVE_LINES)

	add_vertex(Vector3( - size.x, - size.y, 0))
	add_vertex(Vector3( - size.x, size.y, 0))

	add_vertex(Vector3(size.x, size.y, 0))
	add_vertex(Vector3(size.x, - size.y, 0))

	add_vertex(Vector3( - size.x, - size.y, 0))
	add_vertex(Vector3(size.x, - size.y, 0))

	add_vertex(Vector3(size.x, size.y, 0))
	add_vertex(Vector3( - size.x, size.y, 0))

	add_vertex(Vector3.ZERO)
	add_vertex(Vector3.BACK)

	end()
