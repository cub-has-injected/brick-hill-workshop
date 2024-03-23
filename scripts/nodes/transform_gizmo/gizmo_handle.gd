class_name GizmoHandle
extends PickableCollisionObject
tool 

export (Mesh) var mesh:Mesh setget set_mesh
export (Shape) var shape:Shape setget set_shape
export (Material) var material:Material setget set_material
export (bool) var show_dot: = true setget set_show_dot
export (Color) var dot_color: = Color.white setget set_dot_color

func set_mesh(new_mesh:Mesh)->void :
	var scope = Profiler.scope(self, "set_mesh", [new_mesh])

	if mesh != new_mesh:
		mesh = new_mesh
		if is_inside_tree():
			update_mesh()

func set_shape(new_shape:Shape)->void :
	var scope = Profiler.scope(self, "set_shape", [new_shape])

	if shape != new_shape:
		shape = new_shape
		if is_inside_tree():
			update_shape()

func set_material(new_material:Material)->void :
	var scope = Profiler.scope(self, "set_material", [new_material])

	if material != new_material:
		material = new_material
		if is_inside_tree():
			update_material()

func set_show_dot(new_show_dot:bool)->void :
	var scope = Profiler.scope(self, "set_show_dot", [new_show_dot])

	if show_dot != new_show_dot:
		show_dot = new_show_dot
		if is_inside_tree():
			update_show_dot()

func set_hovered(new_hovered:bool)->void :
	var scope = Profiler.scope(self, "set_hovered", [new_hovered])

	var albedo = material.get_albedo()
	albedo.a = 1.0 if new_hovered else 0.75
	material.set_albedo(albedo)

func set_dot_color(new_dot_color:Color)->void :
	var scope = Profiler.scope(self, "set_dot_color", [new_dot_color])

	if dot_color != new_dot_color:
		dot_color = new_dot_color
		$DotMeshInstance.material_override.set_shader_param("color", dot_color)

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	$MeshInstance.mesh = mesh

func update_shape()->void :
	var scope = Profiler.scope(self, "update_shape", [])

	$CollisionShape.shape = shape

func update_material()->void :
	var scope = Profiler.scope(self, "update_material", [])

	$MeshInstance.material_override = material

func update_show_dot()->void :
	var scope = Profiler.scope(self, "update_show_dot", [])

	$DotMeshInstance.visible = show_dot

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	connect("mouse_entered", self, "set_hovered", [true])
	connect("mouse_exited", self, "set_hovered", [false])

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_mesh()
	update_shape()
	update_material()
	update_show_dot()
