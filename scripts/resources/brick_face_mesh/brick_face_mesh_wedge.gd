class_name BrickFaceMeshWedge
extends BrickFaceMesh
tool 


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	return PoolVector3Array([
		Vector3( - 1.0, 1.0, - 1.0) * 0.5, 
		Vector3(1.0, 1.0, - 1.0) * 0.5, 
		Vector3(1.0, - 1.0, 1.0) * 0.5, 
		Vector3( - 1.0, - 1.0, 1.0) * 0.5
	])

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	var verts = get_vertices()
	var slope = verts[0] - verts[ - 1]
	var normal = Vector3.RIGHT.cross(slope.normalized())
	return PoolVector3Array([
		normal, 
		normal, 
		normal, 
		normal
	])

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	return PoolRealArray([
		1.0, 0.0, 0.0, 1.0, 
		1.0, 0.0, 0.0, 1.0, 
		1.0, 0.0, 0.0, 1.0, 
		1.0, 0.0, 0.0, 1.0, 
	])

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	return PoolVector2Array([
		Vector2(0.0, 0.0), 
		Vector2(1.0, 0.0), 
		Vector2(1.0, 1.0), 
		Vector2(0.0, 1.0)
	])

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	var normals = get_normals()
	var normal_vec = normals[0]

	var tangents = get_tangents()
	var tangent_vec = Vector3(tangents[0], tangents[1], tangents[2])
	var binormal_vec = normal_vec.cross(tangent_vec).normalized() * tangents[3]

	var slope_u = abs(extents.dot(tangent_vec))
	var slope_v = abs(extents.dot(binormal_vec.abs()))

	var uv2s = PoolVector2Array()
	for uv in get_uvs():
		uv2s.append(uv * stud_density * Vector2(slope_u, slope_v) * 0.5)
	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	return PoolIntArray([
		0, 1, 2, 0, 2, 3
	])
