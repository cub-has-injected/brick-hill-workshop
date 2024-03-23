extends CSGShape
tool 

export (bool) var update: = false setget set_update

func set_update(new_update:bool)->void :
	var scope = Profiler.scope(self, "set_update", [new_update])

	if update != new_update:
		update_collision_shape()

func update_collision_shape()->void :
	var scope = Profiler.scope(self, "update_collision_shape", [])

	var mesh_arr = get_meshes()
	var trx = mesh_arr[0]
	var array_mesh = mesh_arr[1]

	var shape: = ConcavePolygonShape.new()
	shape.set_faces(array_mesh.get_faces())

	var collision_shape: = CollisionShape.new()
	collision_shape.transform = trx
	collision_shape.set_shape(shape)

	get_parent().add_child_below_node(self, collision_shape)
	if is_inside_tree():
		var edited_scene_root = get_tree().get_edited_scene_root()
		if edited_scene_root:
			collision_shape.set_owner(edited_scene_root)
