class_name BrickCollisionShape
extends CollisionShape
tool 

export (ModelManager.BrickMeshType) var mesh_type = ModelManager.BrickMeshType.CUBE setget set_mesh_type
export (bool) var convex = true setget set_convex


func set_mesh_type(new_mesh_type:int)->void :
	var scope = Profiler.scope(self, "set_mesh_type", [new_mesh_type])

	if mesh_type != new_mesh_type:
		mesh_type = new_mesh_type
		if is_inside_tree():
			mesh_type_changed()

func set_convex(new_convex:bool)->void :
	var scope = Profiler.scope(self, "set_convex", [new_convex])

	if convex != new_convex:
		convex = new_convex
		if is_inside_tree():
			convex_changed()


func get_brick_shape(force_convex:bool = false)->Shape:
	var scope = Profiler.scope(self, "get_brick_shape", [force_convex])

	return ModelManager.get_brick_shape(mesh_type, force_convex)


func mesh_type_changed()->void :
	var scope = Profiler.scope(self, "mesh_type_changed", [])

	update_mesh()

func convex_changed()->void :
	var scope = Profiler.scope(self, "convex_changed", [])

	update_mesh()


func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	set_shape(get_brick_shape(convex))


func _enter_tree():
	var scope = Profiler.scope(self, "_enter_tree", [])

	mesh_type_changed()
