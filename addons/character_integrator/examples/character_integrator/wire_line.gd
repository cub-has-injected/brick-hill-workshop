class_name WireLine
tool 

static func draw(geo:ImmediateGeometry, from:Vector3, to:Vector3, color:Color = Color.white)->void :
	geo.begin(Mesh.PRIMITIVE_LINES)

	geo.set_color(color)
	geo.add_vertex(from)
	geo.add_vertex(to)

	geo.end()

static func draw_relative(geo:ImmediateGeometry, origin:Vector3, delta:Vector3, color:Color = Color.white)->void :
	draw(geo, origin, origin + delta, color)
