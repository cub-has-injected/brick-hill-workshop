"\nDebug visualization for objects implementing InterfaceSize\n"

class_name SizeDebugGeo
extends ImmediateGeometry
tool 

export (NodePath) var target setget set_target

var _cached_size:Vector3

func set_target(new_target:NodePath)->void :
	var scope = Profiler.scope(self, "set_target", [new_target])

	if target != new_target:
		target = new_target
		if is_inside_tree():
			update_target()

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	update_target()

func update_target()->void :
	var scope = Profiler.scope(self, "update_target", [])

	var node = get_node_or_null(target)
	assert (node != null, "Invalid target")
	assert (InterfaceSize.is_implementor(node), "SizeDebugGeo targets must implement InterfaceSize")

	var size = InterfaceSize.get_size(node)
	if size != _cached_size:
		rebuild(size)
		_cached_size = size

func rebuild(size:Vector3)->void :
	var start = - size * 0.5
	var end = size * 0.5

	var top_vertices: = [
		Vector3(start.x, start.y, start.z), 
		Vector3(end.x, start.y, start.z), 
		Vector3(end.x, start.y, end.z), 
		Vector3(start.x, start.y, end.z)
	]

	var bottom_vertices: = [
		Vector3(start.x, end.y, start.z), 
		Vector3(end.x, end.y, start.z), 
		Vector3(end.x, end.y, end.z), 
		Vector3(start.x, end.y, end.z)
	]

	clear()

	begin(Mesh.PRIMITIVE_LINE_STRIP)
	add_vertex(top_vertices[0])
	add_vertex(top_vertices[1])
	add_vertex(top_vertices[2])
	add_vertex(top_vertices[3])
	add_vertex(top_vertices[0])
	end()

	begin(Mesh.PRIMITIVE_LINE_STRIP)
	add_vertex(bottom_vertices[0])
	add_vertex(bottom_vertices[1])
	add_vertex(bottom_vertices[2])
	add_vertex(bottom_vertices[3])
	add_vertex(bottom_vertices[0])
	end()

	begin(Mesh.PRIMITIVE_LINES)
	add_vertex(top_vertices[0])
	add_vertex(bottom_vertices[0])

	add_vertex(top_vertices[1])
	add_vertex(bottom_vertices[1])

	add_vertex(top_vertices[2])
	add_vertex(bottom_vertices[2])

	add_vertex(top_vertices[3])
	add_vertex(bottom_vertices[3])
	end()
