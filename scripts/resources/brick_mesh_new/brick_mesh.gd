class_name BrickMesh
extends ArrayMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return []

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return []

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return []

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray()

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	var surface_bases: = get_surface_bases()
	var closest_dot: = - 1.0
	var closest_index: = - 1

	for i in range(0, surface_bases.size()):
		var candidate_dot = surface_bases[i].y.dot(normal)
		if candidate_dot > closest_dot:
			closest_dot = candidate_dot
			closest_index = i

	return closest_index

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	for _i in range(0, get_surface_count()):
		surface_remove(0)

	var surface_meshes = get_surface_meshes()
	var surface_bases = get_surface_bases()
	var surface_origins = get_surface_origins()

	var vertices: = PoolVector3Array()
	var normals: = PoolVector3Array()
	var tangents: = PoolRealArray()
	var uvs: = PoolVector2Array()
	var uv2s: = PoolVector2Array()
	var indices: = PoolIntArray()

	for i in range(0, surface_meshes.size()):
		var transform_trs = Transform(surface_bases[i], surface_origins[i])
		var transform_r = transform_trs
		transform_r.origin = Vector3.ZERO
		transform_r.basis = transform_r.basis.orthonormalized()

		var surf = surface_meshes[i]

		
		for index in surf.get_indices():
			indices.append(index + vertices.size())

		
		var surf_vertices = surf.get_vertices()
		vertices.append_array(transform_trs.xform(surf_vertices))

		
		normals.append_array(transform_r.xform(surf.get_normals()))

		
		var surf_tangents = surf.get_tangents()
		for j in range(0, surf_tangents.size(), 4):
			var tangent = Vector3(
				surf_tangents[j], 
				surf_tangents[j + 1], 
				surf_tangents[j + 2]
			)
			tangent = transform_r.xform(tangent)

			surf_tangents[j] = tangent.x
			surf_tangents[j + 1] = tangent.y
			surf_tangents[j + 2] = tangent.z

		tangents.append_array(surf_tangents)

		
		uvs.append_array(surf.get_uvs())

		
		for vert in surf_vertices:
			uv2s.append(Vector2(i, 0))

	add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, [
		vertices, 
		normals, 
		tangents, 
		null, 
		uvs, 
		uv2s, 
		null, 
		null, 
		indices
	])

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	update_mesh()
