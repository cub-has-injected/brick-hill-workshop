class_name BrickFaceMeshIcosphere
extends BrickFaceMesh
tool 

const X: = 0.525731
const Z: = 0.850651

const BASE_VERTICES: = PoolVector3Array([
	Vector3( - X, 0.0, Z), Vector3(X, 0.0, Z), Vector3( - X, 0.0, - Z), Vector3(X, 0.0, - Z), 
	Vector3(0.0, Z, X), Vector3(0.0, Z, - X), Vector3(0.0, - Z, X), Vector3(0.0, - Z, - X), 
	Vector3(Z, X, 0.0), Vector3( - Z, X, 0.0), Vector3(Z, - X, 0.0), Vector3( - Z, - X, 0.0)
])

const BASE_INDICES = PoolIntArray([
	0, 4, 1, 
	0, 9, 4, 
	9, 5, 4, 
	4, 5, 8, 
	4, 8, 1, 
	8, 10, 1, 
	8, 3, 10, 
	5, 3, 8, 
	5, 2, 3, 
	2, 7, 3, 
	7, 10, 3, 
	7, 6, 10, 
	7, 11, 6, 
	11, 0, 6, 
	0, 1, 6, 
	6, 1, 10, 
	9, 0, 11, 
	9, 11, 2, 
	9, 2, 5, 
	7, 2, 11
])

const SUBDIV = 2
var subdiv_vertices: = PoolVector3Array()
var subdiv_indices: = PoolIntArray()

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	for i in range(0, BASE_INDICES.size(), 3):
		var i1 = BASE_INDICES[i]
		var i2 = BASE_INDICES[i + 1]
		var i3 = BASE_INDICES[i + 2]
		var v1 = BASE_VERTICES[i1]
		var v2 = BASE_VERTICES[i2]
		var v3 = BASE_VERTICES[i3]
		subdivide(v1, v2, v3, SUBDIV)

func subdivide(v1:Vector3, v2:Vector3, v3:Vector3, depth:int)->void :
	var scope = Profiler.scope(self, "subdivide", [v1, v2, v3, depth])

	var v12:Vector3
	var v23:Vector3
	var v31:Vector3

	if depth == 0:
		subdiv_vertices.append_array([v1, v2, v3])
		subdiv_indices.append_array([
			subdiv_vertices.size() - 3, 
			subdiv_vertices.size() - 2, 
			subdiv_vertices.size() - 1
		])
		return 

	for i in range(0, 3):
		v12[i] = v1[i] + v2[i]
		v23[i] = v2[i] + v3[i]
		v31[i] = v3[i] + v1[i]

	v12 = v12.normalized()
	v23 = v23.normalized()
	v31 = v31.normalized()

	subdivide(v1, v12, v31, depth - 1)
	subdivide(v2, v23, v12, depth - 1)
	subdivide(v3, v31, v23, depth - 1)
	subdivide(v12, v23, v31, depth - 1)


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	var vertices = PoolVector3Array()
	for vertex in subdiv_vertices:
		vertices.append(vertex)
	return vertices

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	var vertices = get_vertices()
	var normals = PoolVector3Array()
	for vertex in vertices:
		normals.append(vertex.normalized())
	return normals

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	var normals = get_normals()
	var tangents = PoolRealArray()
	for normal in normals:
		if normal == Vector3.UP or normal == Vector3.DOWN:
			tangents.append_array([1.0, 0.0, 0.0, 1.0])
		else :
			var tangent = normal.cross(Vector3.DOWN)
			tangent.y = 0.0
			tangent = - tangent.normalized()
			tangents.append_array([tangent.x, tangent.y, tangent.z, - 1.0])
	return tangents

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	var normals = get_normals()
	var uvs = PoolVector2Array()
	for normal in normals:
		var k_one_over_pi = 1.0 / PI
		var u = 0.5 - 0.5 * atan2(normal.x, - normal.z) * k_one_over_pi
		var v = 1.0 - acos(normal.y) * k_one_over_pi
		uvs.append(Vector2(u * 3.0, (v + 0.25) * 1.5))
	return uvs

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	var uvs = get_uvs()
	var uv2s = PoolVector2Array()

	for uv in uvs:
		uv2s.append(uv * stud_density * extents.x)

	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	return subdiv_indices
