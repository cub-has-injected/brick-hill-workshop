class_name WavefrontObjMesh
extends ArrayMesh
tool 

signal build_complete()


var wavefront_obj:WavefrontObj setget set_wavefront_obj
var center: = Vector3.ZERO


var start_ts: = - 1
var job_system:JobSystem = null
var surface_arrays: = {}


func set_wavefront_obj(new_wavefront_obj:WavefrontObj)->void :
	var scope = Profiler.scope(self, "set_wavefront_obj", [new_wavefront_obj])

	if not new_wavefront_obj:
		new_wavefront_obj = WavefrontObj.new()

	if wavefront_obj != new_wavefront_obj and new_wavefront_obj is WavefrontObj:
		if wavefront_obj and wavefront_obj.is_connected("changed", self, "update_mesh"):
			wavefront_obj.disconnect("changed", self, "update_mesh")

		if wavefront_obj and wavefront_obj.is_connected("cleared", self, "update_mesh"):
			wavefront_obj.disconnect("cleared", self, "update_mesh")

		wavefront_obj = new_wavefront_obj

		if wavefront_obj and not wavefront_obj.is_connected("cleared", self, "update_mesh"):
			wavefront_obj.connect("cleared", self, "update_mesh")

		if wavefront_obj and not wavefront_obj.is_connected("changed", self, "update_mesh"):
			wavefront_obj.connect("changed", self, "update_mesh")


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	job_system = JobSystem.new()
	job_system.connect("jobs_finished", self, "build_complete")


func hash_vertex(vertex:Vector3, normal:Vector3, uv:Vector2)->String:
	var scope = Profiler.scope(self, "hash_vertex", [vertex, normal, uv])

	return "%s %s %s" % [vertex, normal, uv]

func triangulate(vertex_indices:PoolIntArray)->Array:
	var scope = Profiler.scope(self, "triangulate", [vertex_indices])

	var triangle_indices: = []
	for i in range(0, vertex_indices.size() - 2):
		triangle_indices.append(0)
		triangle_indices.append(i + 1)
		triangle_indices.append(i)
		triangle_indices.append(0)
		triangle_indices.append(i + 2)
		triangle_indices.append(i + 1)
	return triangle_indices

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	for i in get_surface_count():
		surface_remove(0)

	if not wavefront_obj:
		return 

	set_name(wavefront_obj.get_name())

	if wavefront_obj.geometries_face.size() == 0:
		return 

	start_ts = OS.get_ticks_msec()

	surface_arrays = {}

	var groups = wavefront_obj.get_unique_groups()
	var group_geometries: = {}
	for group in groups:
		group_geometries[group] = wavefront_obj.get_face_geometries_by_group(group)

	job_system.run_jobs_array_each(self, "build_group", group_geometries.size(), {"group_geometries":group_geometries})

func build_group(userdata:Dictionary)->Dictionary:
	var scope = Profiler.scope(self, "build_group", [userdata])

	var job_index = userdata.job_index

	var group_geometries = userdata.group_geometries
	var group = group_geometries.keys()[job_index]
	var face_geometries = group_geometries.values()[job_index]

	var model_index_hashes: = {}

	var model_vertices: = PoolVector3Array()
	var model_normals: = PoolVector3Array()
	var model_tangents: = PoolRealArray()
	var model_uvs: = PoolVector2Array()
	var model_indices: = PoolIntArray()
	for geometry_face in face_geometries:
		for i in triangulate(geometry_face.vertex_indices):
			var vertex_idx = geometry_face.vertex_indices[i]
			var normal_idx = geometry_face.normal_indices[i]
			var uv_idx = geometry_face.uv_indices[i]

			var vertex = Vector3(
				wavefront_obj.vertices_geometric[vertex_idx * 4], 
				wavefront_obj.vertices_geometric[vertex_idx * 4 + 1], 
				wavefront_obj.vertices_geometric[vertex_idx * 4 + 2]
			)
			var normal = Vector3(0, 0, 1)
			if normal_idx >= 0 and normal_idx <= wavefront_obj.vertices_normal.size() - 1:
					normal = wavefront_obj.vertices_normal[normal_idx]

			var uv = Vector2(0, 0)
			if uv_idx >= 0 and uv_idx <= wavefront_obj.vertices_texture.size() - 1:
				uv = Vector2(
					wavefront_obj.vertices_texture[uv_idx].x, 
					wavefront_obj.vertices_texture[uv_idx].y
				)

			var vert_hash = hash_vertex(vertex, normal, uv)
			if not vert_hash in model_index_hashes:
				model_vertices.append(vertex)
				model_normals.append(normal)

				var tangent:Vector3
				if normal == Vector3.UP:
					tangent = Vector3.RIGHT
				elif normal == Vector3.DOWN:
					tangent = Vector3.LEFT
				else :
					tangent = normal.cross(Vector3.UP).normalized()
				model_tangents.append_array([tangent.x, tangent.y, tangent.z, 1.0])

				model_uvs.append(uv)
				model_index_hashes[vert_hash] = model_index_hashes.size()

			model_indices.append(model_index_hashes[vert_hash])

	job_system.call_deferred("job_finished", job_index)
	return {
		"name":group, 
		"vertex_arrays":[
			model_vertices, 
			model_normals, 
			model_tangents, 
			null, 
			model_uvs, 
			null, 
			null, 
			null, 
			model_indices
		]
	}

func build_complete(job_results:Dictionary)->void :
	var scope = Profiler.scope(self, "build_complete", [job_results])

	center = Vector3.ZERO
	var vertices: = 0

	for i in range(0, job_results.size()):
		for vertex in job_results[i].vertex_arrays[0]:
			center += vertex
			vertices += 1

	center /= vertices

	for i in range(0, job_results.size()):
		add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, job_results[i].vertex_arrays)
		surface_set_name(get_surface_count() - 1, job_results[i].name)

	emit_signal("build_complete")

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	return [
		{
			"name":"wavefront_obj", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"Resource"
		}
	]
