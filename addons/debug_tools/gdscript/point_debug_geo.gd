"\nDebug visualization for a point in 3D space\n"

class_name PointDebugGeo
extends ImmediateGeometry
tool 

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	clear()

	material_override = SpatialMaterial.new()
	material_override.flags_unshaded = true
	material_override.vertex_color_use_as_albedo = true

	begin(Mesh.PRIMITIVE_LINES)

	set_color(Color.red)
	add_vertex(Vector3.LEFT)
	add_vertex(Vector3.RIGHT)

	set_color(Color.green)
	add_vertex(Vector3.UP)
	add_vertex(Vector3.DOWN)

	set_color(Color.blue)
	add_vertex(Vector3.FORWARD)
	add_vertex(Vector3.BACK)

	end()
