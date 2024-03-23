extends ImmediateGeometry
tool 

func _ready()->void :
	clear()
	begin(Mesh.PRIMITIVE_LINES)
	set_color(Color.white)
	add_vertex(Vector3.ZERO)
	add_vertex(Vector3.ONE)
	end()
