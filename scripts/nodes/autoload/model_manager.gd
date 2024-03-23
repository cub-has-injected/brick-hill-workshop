class_name WorkshopModelManager
extends Node
tool 

enum BrickMeshType{
	CUBE, 
	CYLINDER, 
	CYLINDER_HALF, 
	CYLINDER_QUARTER, 
	INVERSE_CYLINDER_HALF, 
	INVERSE_CYLINDER_QUARTER, 
	SPHERE, 
	SPHERE_HALF, 
	SPHERE_QUARTER, 
	SPHERE_EIGTH, 
	WEDGE, 
	WEDGE_CORNER, 
	WEDGE_EDGE, 
}

const PRINT: = false

var dir: = Directory.new()

var search_paths: = PoolStringArray([
	"user://models/"
])

var brick_meshes: = {
	BrickMeshType.CUBE:BrickMeshCube.new(), 
	BrickMeshType.CYLINDER:BrickMeshCylinder.new(), 
	BrickMeshType.CYLINDER_HALF:BrickMeshCylinderHalf.new(), 
	BrickMeshType.CYLINDER_QUARTER:BrickMeshCylinderQuarter.new(), 
	BrickMeshType.INVERSE_CYLINDER_HALF:BrickMeshInverseCylinderHalf.new(), 
	BrickMeshType.INVERSE_CYLINDER_QUARTER:BrickMeshInverseCylinderQuarter.new(), 
	BrickMeshType.SPHERE:BrickMeshSphere.new(), 
	BrickMeshType.SPHERE_HALF:BrickMeshSphereHalf.new(), 
	BrickMeshType.SPHERE_QUARTER:BrickMeshSphereQuarter.new(), 
	BrickMeshType.SPHERE_EIGTH:BrickMeshSphereEigth.new(), 
	BrickMeshType.WEDGE:BrickMeshWedge.new(), 
	BrickMeshType.WEDGE_CORNER:BrickMeshWedgeCorner.new(), 
	BrickMeshType.WEDGE_EDGE:BrickMeshWedgeEdge.new(), 
}

var brick_convex_shapes: = {
	BrickMeshType.CUBE:BoxShape.new(), 
	BrickMeshType.CYLINDER:ConvexPolygonShape.new(), 
	BrickMeshType.CYLINDER_HALF:ConvexPolygonShape.new(), 
	BrickMeshType.CYLINDER_QUARTER:ConvexPolygonShape.new(), 
	BrickMeshType.INVERSE_CYLINDER_HALF:ConvexPolygonShape.new(), 
	BrickMeshType.INVERSE_CYLINDER_QUARTER:ConvexPolygonShape.new(), 
	BrickMeshType.SPHERE:SphereShape.new(), 
	BrickMeshType.SPHERE_HALF:ConvexPolygonShape.new(), 
	BrickMeshType.SPHERE_QUARTER:ConvexPolygonShape.new(), 
	BrickMeshType.SPHERE_EIGTH:ConvexPolygonShape.new(), 
	BrickMeshType.WEDGE:ConvexPolygonShape.new(), 
	BrickMeshType.WEDGE_CORNER:ConvexPolygonShape.new(), 
	BrickMeshType.WEDGE_EDGE:ConvexPolygonShape.new(), 
}

var brick_concave_shapes: = {
	BrickMeshType.CUBE:ConcavePolygonShape.new(), 
	BrickMeshType.CYLINDER:ConcavePolygonShape.new(), 
	BrickMeshType.CYLINDER_HALF:ConcavePolygonShape.new(), 
	BrickMeshType.CYLINDER_QUARTER:ConcavePolygonShape.new(), 
	BrickMeshType.INVERSE_CYLINDER_HALF:ConcavePolygonShape.new(), 
	BrickMeshType.INVERSE_CYLINDER_QUARTER:ConcavePolygonShape.new(), 
	BrickMeshType.SPHERE:ConcavePolygonShape.new(), 
	BrickMeshType.SPHERE_HALF:ConcavePolygonShape.new(), 
	BrickMeshType.SPHERE_QUARTER:ConcavePolygonShape.new(), 
	BrickMeshType.SPHERE_EIGTH:ConcavePolygonShape.new(), 
	BrickMeshType.WEDGE:ConcavePolygonShape.new(), 
	BrickMeshType.WEDGE_CORNER:ConcavePolygonShape.new(), 
	BrickMeshType.WEDGE_EDGE:ConcavePolygonShape.new(), 
}

var model_meshes: = {}
var model_shapes: = {}

func get_model_paths()->Dictionary:
	var scope = Profiler.scope(self, "get_model_paths", [])

	if PRINT:
		print_debug("%s get model paths. search paths: %s" % [get_name(), search_paths])

	var model_paths: = {}

	for search_path in search_paths:
		var change_dir_error = dir.open(search_path)
		if change_dir_error:
			printerr("Change dir error for path %s: %s" % [search_path, BrickHillUtil.get_error_string(change_dir_error)])
			return {}

		var list_dir_error = dir.list_dir_begin(true, true)
		if list_dir_error:
			printerr("List dir error for path %s: %s" % [search_path, BrickHillUtil.get_error_string(list_dir_error)])
			return {}

		while true:
			var element = dir.get_next()
			if not element:
				break

			var element_comps = element.split(".")
			var element_extension = element_comps[ - 1]
			if element_extension != "obj":
				continue

			element_comps.remove(element_comps.size() - 1)
			var element_name = element_comps.join(".")

			model_paths[element_name] = search_path + "/" + element_name + "." + element_extension

	return model_paths

func get_brick_mesh(brick_type:int)->ArrayMesh:
	var scope = Profiler.scope(self, "get_brick_mesh", [brick_type])

	if PRINT:
		print_debug("%s get brick mesh for %s" % [get_name(), BrickMeshType.keys()[brick_type].capitalize()])

	if not brick_type in brick_meshes:
		return null

	return brick_meshes[brick_type]

func get_brick_mesh_surface_count(brick_type:int)->int:
	var scope = Profiler.scope(self, "get_brick_mesh_surface_count", [brick_type])

	match brick_type:
		BrickMeshType.CUBE:
			return 6
		BrickMeshType.CYLINDER:
			return 3
		BrickMeshType.CYLINDER_HALF:
			return 4
		BrickMeshType.CYLINDER_QUARTER:
			return 5
		BrickMeshType.INVERSE_CYLINDER_HALF:
			return 6
		BrickMeshType.INVERSE_CYLINDER_QUARTER:
			return 5
		BrickMeshType.SPHERE:
			return 6
		BrickMeshType.SPHERE_HALF:
			return 6
		BrickMeshType.SPHERE_QUARTER:
			return 6
		BrickMeshType.SPHERE_EIGTH:
			return 6
		BrickMeshType.WEDGE:
			return 5
		BrickMeshType.WEDGE_CORNER:
			return 7
		BrickMeshType.WEDGE_EDGE:
			return 5
	return - 1

func get_brick_surface_name(brick_type:int, surface_index:int)->String:
	var scope = Profiler.scope(self, "get_brick_surface_name", [brick_type, surface_index])

	return get_brick_mesh(brick_type).get_surface_names()[surface_index]

func get_brick_mesh_hovered_face_idx(brick_type:int, normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_brick_mesh_hovered_face_idx", [brick_type, normal])

	return get_brick_mesh(brick_type).get_hovered_face_idx(normal)

func get_brick_shape(brick_type:int, force_convex:bool = false)->Shape:
	var scope = Profiler.scope(self, "get_brick_shape", [brick_type, force_convex])

	if PRINT:
		print_debug("%s get brick shape for %s" % [get_name(), BrickMeshType.keys()[brick_type].capitalize()])

	if brick_type in brick_concave_shapes and not force_convex:
		return brick_concave_shapes[brick_type]

	if brick_type in brick_convex_shapes:
		return brick_convex_shapes[brick_type]

	return null

func get_model_mesh(model_name:String)->WavefrontObjMesh:
	var scope = Profiler.scope(self, "get_model_mesh", [model_name])

	if PRINT:
		print_debug("%s get model mesh for %s" % [get_name(), model_name])

	if not model_name in model_meshes:
		return null

	return model_meshes[model_name]

func get_model_shape(model_name:String)->ConvexPolygonShape:
	var scope = Profiler.scope(self, "get_model_shape", [model_name])

	if PRINT:
		print_debug("%s get model shape for %s" % [get_name(), model_name])

	if not model_name in model_shapes:
		return null

	return model_shapes[model_name]

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	if PRINT:
		print_debug("%s init" % [get_name()])

	update_bricks()
	update_models()

func update_bricks()->void :
	var scope = Profiler.scope(self, "update_bricks", [])

	if PRINT:
		print_debug("%s update bricks" % [get_name()])

	for i in range(0, brick_meshes.size()):
		if brick_convex_shapes[i] is BoxShape:
			brick_convex_shapes[i].extents = Vector3.ONE * 0.5
		elif brick_convex_shapes[i] is SphereShape:
			brick_convex_shapes[i].radius = 0.5
		elif brick_convex_shapes[i] is ConvexPolygonShape:
			generate_convex_collision(brick_meshes[i], brick_convex_shapes[i])

		if i in brick_concave_shapes and brick_concave_shapes[i] is ConcavePolygonShape:
			generate_concave_collision(brick_meshes[i], brick_concave_shapes[i])

func update_models()->void :
	var scope = Profiler.scope(self, "update_models", [])

	if PRINT:
		print_debug("%s update models" % [get_name()])

	model_meshes.clear()
	model_shapes.clear()

	model_meshes["flag"] = preload("res://models/flag.tres")
	model_shapes["flag"] = ConvexPolygonShape.new()
	generate_convex_collision(model_meshes["flag"], model_shapes["flag"])

	var model_paths = get_model_paths()
	if PRINT:
		print_debug("%s model paths: %s" % [get_name(), model_paths])
	for model_name in model_paths:
		if PRINT:
			print_debug("%s building model %s" % [get_name(), model_name])
		model_meshes[model_name] = WavefrontObjMesh.new()
		model_shapes[model_name] = ConvexPolygonShape.new()

		model_meshes[model_name].connect("build_complete", self, "mesh_build_complete", [model_name])

		var wavefront_obj: = WavefrontObj.new()
		model_meshes[model_name].set_wavefront_obj(wavefront_obj)

		wavefront_obj.path = model_paths[model_name]
		wavefront_obj.set_reload(true)

func mesh_build_complete(model_name:String):
	var scope = Profiler.scope(self, "mesh_build_complete", [model_name])

	if PRINT:
		print_debug("%s mesh build complete" % [get_name()])

	generate_convex_collision(model_meshes[model_name], model_shapes[model_name])

func generate_convex_collision(mesh:ArrayMesh, shape:ConvexPolygonShape)->void :
	var scope = Profiler.scope(self, "generate_convex_collision", [mesh, shape])

	if PRINT:
		print_debug("%s generate convex collision for %s from %s" % [get_name(), shape, mesh])

	var mesh_center = get_mesh_center(mesh)

	var unique_vertices: = []
	for i in range(0, mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(i)
		var vertices = arrays[0]
		var indices = arrays[8]
		for index in indices:
			var vertex = vertices[index]
			var unique = true

			var model_vertex = vertex - mesh_center

			for comp_vertex in unique_vertices:
				var delta = model_vertex - comp_vertex
				var delta_len = delta.length()
				if delta_len < 0.0001:
					unique = false
					break

			if unique:
				unique_vertices.append(model_vertex)

	shape.set_points(unique_vertices)

func generate_concave_collision(mesh:ArrayMesh, shape:ConcavePolygonShape)->void :
	var scope = Profiler.scope(self, "generate_concave_collision", [mesh, shape])

	if PRINT:
		print_debug("%s generate concave collision for %s from %s" % [get_name(), shape, mesh])

	var mesh_center = get_mesh_center(mesh)

	var collision_verts: = []
	for i in range(0, mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(i)
		var vertices = arrays[0]
		var indices = arrays[8]
		for index in indices:
			var vertex = vertices[index]
			var model_vertex = vertex - mesh_center
			collision_verts.append(model_vertex)

	shape.set_faces(collision_verts)

func get_mesh_center(mesh:ArrayMesh)->Vector3:
	var scope = Profiler.scope(self, "get_mesh_center", [mesh])

	if mesh is WavefrontObjMesh:
		return mesh.center
	return Vector3.ZERO
