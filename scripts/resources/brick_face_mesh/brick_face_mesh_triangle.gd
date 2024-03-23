class_name BrickFaceMeshTriangle
extends BrickFaceMesh
tool 

var vertices: = PoolVector3Array()
var uvs: = PoolVector2Array()

var flip_binormal: = false
var flip_tangent: = false


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	var out_verts: = PoolVector3Array()
	for vert in vertices:
		out_verts.append(vert)
	return out_verts

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	var v0v1 = vertices[1] - vertices[0]
	var v0v2 = vertices[2] - vertices[0]
	var normal = v0v2.normalized().cross(v0v1.normalized()).normalized()
	return PoolVector3Array([
		normal, 
		normal, 
		normal
	])

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	var v2v1 = vertices[1] - vertices[2]
	var tangent_vec = v2v1.normalized() * ( - 1.0 if flip_tangent else 1.0)
	var tangent: = PoolRealArray([tangent_vec.x, tangent_vec.y, tangent_vec.z, ( - 1.0 if flip_binormal else 1.0)])
	var tangents: = PoolRealArray()
	tangents.append_array(tangent)
	tangents.append_array(tangent)
	tangents.append_array(tangent)
	return tangents

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	return uvs

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
	for uv in uvs:
		uv2s.append(uv * stud_density * Vector2(slope_u, slope_v) * 0.5)
	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	return PoolIntArray([
		0, 1, 2
	])


func _init(in_vertices:PoolVector3Array, in_uvs:PoolVector2Array, in_flip_tangent:bool = false, in_flip_binormal:bool = false)->void :
	var scope = Profiler.scope(self, "_init", [in_vertices, in_uvs, in_flip_tangent, in_flip_binormal])

	vertices = in_vertices
	uvs = in_uvs
	flip_tangent = in_flip_tangent
	flip_binormal = in_flip_binormal
