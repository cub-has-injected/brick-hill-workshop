class_name BrickFaceMeshCubeSphere
extends BrickFaceMesh
tool 

const DIV_COUNT = 8

var vertices: = PoolVector3Array()
var uvs: = PoolVector2Array()

var half_u = false
var half_v = false
var uv_scale = Vector2.ONE

func _init(in_half_u:bool, in_half_v:bool, in_uv_scale:Vector2 = Vector2.ONE)->void :
	var scope = Profiler.scope(self, "_init", [in_half_u, in_half_v, in_uv_scale])

	half_u = in_half_u
	half_v = in_half_v
	uv_scale = in_uv_scale

	for j in range(0, DIV_COUNT):
		for i in range(0, DIV_COUNT):
			var u = float(i) / (DIV_COUNT - 1)
			var v = float(j) / (DIV_COUNT - 1)

			var u_axis = Vector3.RIGHT
			var v_axis = Vector3.FORWARD

			if half_u:
				u_axis *= u
			else :
				u_axis *= u * 2.0 - 1.0

			if half_v:
				v_axis *= v
			else :
				v_axis *= v * 2.0 - 1.0

			var fp = Vector3.UP + (u_axis + v_axis)
			var sp = fp * fp

			var s = Vector3.ZERO
			s.x = fp.x * sqrt(1.0 - sp.y / 2.0 - sp.z / 2.0 + sp.y * sp.z / 3.0)
			s.y = fp.y * sqrt(1.0 - sp.x / 2.0 - sp.z / 2.0 + sp.x * sp.z / 3.0)
			s.z = fp.z * sqrt(1.0 - sp.x / 2.0 - sp.y / 2.0 + sp.x * sp.y / 3.0)

			vertices.append(s.normalized() * 0.5)

			var uv = Vector2(u, 1.0 - v)

			if half_u:
				uv.x *= 0.5

			if half_v:
				uv.y *= 0.5

			uv -= Vector2.ONE * 0.5
			uvs.append(uv * uv_scale)


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	return vertices

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	var normals = PoolVector3Array()
	for vertex in vertices:
		normals.append(vertex.normalized())
	return normals

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	var verts = get_vertices()
	var tangents = PoolRealArray()
	for i in range(0, verts.size()):
		if i % DIV_COUNT == DIV_COUNT - 1:
			var v1 = verts[i - 1]
			var v2 = verts[i]
			var tangent = (v2 - v1).normalized()
			tangents.append_array([tangent.x, tangent.y, tangent.z, 1.0])
		else :
			var v1 = verts[i]
			var v2 = verts[i + 1]
			var tangent = (v2 - v1).normalized()
			tangents.append_array([tangent.x, tangent.y, tangent.z, 1.0])
	return tangents

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	return uvs

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	var uv2s = PoolVector2Array()
	for uv in uvs:
		uv2s.append(uv * stud_density * Vector2(extents.x, extents.z) * 0.5)
	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	var indices = PoolIntArray()
	for i in range(0, vertices.size() - DIV_COUNT - 1, 2):
		indices.append(i)
		indices.append(i + DIV_COUNT)
		indices.append(i + 1)
		indices.append(i + 1)
		indices.append(i + DIV_COUNT)
		indices.append(i + 1 + DIV_COUNT)

		if i % DIV_COUNT < DIV_COUNT - 2:
			indices.append(1 + i)
			indices.append(1 + i + DIV_COUNT)
			indices.append(1 + i + 1)
			indices.append(1 + i + 1)
			indices.append(1 + i + DIV_COUNT)
			indices.append(1 + i + 1 + DIV_COUNT)
	return indices
