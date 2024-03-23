"\n2D grid composed of Mesh.PRIMITIVE_LINES\n"

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

	for x in range(0, size.x * 2 + 1):
		add_vertex(Vector3( - size.x + x, 0, - size.y))
		add_vertex(Vector3( - size.x + x, 0, size.y))

	for y in range(0, size.y * 2 + 1):
		add_vertex(Vector3( - size.x, 0, - size.y + y))
		add_vertex(Vector3(size.x, 0, - size.y + y))

	end()
