class_name WireCylinder
extends ImmediateGeometry
tool 

export (float) var radius: = 2.0 setget set_radius
export (float) var height: = 2.0 setget set_height

func set_radius(new_radius:float)->void :
	if radius != new_radius:
		radius = new_radius
		rebuild()

func set_height(new_height:float)->void :
	if height != new_height:
		height = new_height
		rebuild()

func _enter_tree():
	rebuild()

func rebuild()->void :
	clear()

	var half_height = height * 0.5

	add_circle(Vector3.UP * half_height)
	add_circle(Vector3.DOWN * half_height)

	begin(Mesh.PRIMITIVE_LINES)
	add_vertex(Vector3.FORWARD * radius + Vector3.UP * half_height)
	add_vertex(Vector3.FORWARD * radius + Vector3.DOWN * half_height)

	add_vertex(Vector3.BACK * radius + Vector3.UP * half_height)
	add_vertex(Vector3.BACK * radius + Vector3.DOWN * half_height)

	add_vertex(Vector3.LEFT * radius + Vector3.UP * half_height)
	add_vertex(Vector3.LEFT * radius + Vector3.DOWN * half_height)

	add_vertex(Vector3.RIGHT * radius + Vector3.UP * half_height)
	add_vertex(Vector3.RIGHT * radius + Vector3.DOWN * half_height)
	end()


func add_circle(origin:Vector3):
	begin(Mesh.PRIMITIVE_LINE_LOOP)
	var rad = 0.0
	for i in range(0, 16):
		add_vertex(origin + Vector3.FORWARD.rotated(Vector3.UP, rad) * radius)
		rad += TAU / 16
	end()
