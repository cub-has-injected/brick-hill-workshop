class_name BrickFaceMeshQuad
extends BrickFaceMesh
tool 


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	return PoolVector3Array([
		Vector3( - 1.0, 0.0, - 1.0) * 0.5, 
		Vector3(1.0, 0.0, - 1.0) * 0.5, 
		Vector3(1.0, 0.0, 1.0) * 0.5, 
		Vector3( - 1.0, 0.0, 1.0) * 0.5
	])

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	return PoolVector3Array([
		Vector3.UP, 
		Vector3.UP, 
		Vector3.UP, 
		Vector3.UP
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

	var uvs = get_uvs()
	var uv2s = PoolVector2Array()

	var u_extents = extents.dot(transform.basis.x)
	var v_extents = extents.dot(transform.basis.z)

	for uv in uvs:
		uv2s.append(uv * stud_density * Vector2(u_extents, v_extents).abs() * 0.5)

	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	return PoolIntArray([
		0, 1, 2, 0, 2, 3
	])
