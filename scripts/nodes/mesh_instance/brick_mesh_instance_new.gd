class_name BrickMeshInstanceNew
extends MeshInstance
tool 

export (ModelManager.BrickMeshType) var mesh_type = ModelManager.BrickMeshType.CUBE setget set_mesh_type

func set_mesh_type(new_mesh_type:int)->void :
	var scope = Profiler.scope(self, "set_mesh_type", [new_mesh_type])

	if mesh_type != new_mesh_type:
		mesh_type = new_mesh_type
		if is_inside_tree():
			mesh_type_changed()

func mesh_type_changed()->void :
	var scope = Profiler.scope(self, "mesh_type_changed", [])

	update_mesh()

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	set_mesh(ModelManager.get_brick_mesh(mesh_type))

func _enter_tree():
	var scope = Profiler.scope(self, "_enter_tree", [])

	mesh_type_changed()
