class_name BrickFaceMeshCircle
extends BrickFaceMesh
tool 

const SIDES = 32

var radius: = 1.0
var circ_factor: = 1.0
var flip: = false
var uv_scale: = Vector2.ONE


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	var vertices = PoolVector3Array()

	if flip:
		vertices.append(Vector3( - 1.0, 0.0, - 1.0) * radius)
		vertices.append(Vector3( - 1.0, 0.0, 1.0) * radius)
		vertices.append(Vector3(1.0, 0.0, - 1.0) * radius)
		vertices.append(Vector3(1.0, 0.0, 1.0) * radius)
	else :
		vertices.append(Vector3.ZERO)
		vertices.append(Vector3.ZERO)
		vertices.append(Vector3.ZERO)
		vertices.append(Vector3.ZERO)

	for side in range(0, SIDES):
		var vertex = radius * Vector3.FORWARD.rotated(Vector3.UP, (float(side) / float(SIDES - 1)) * TAU * circ_factor)
		vertices.append(vertex)
	return vertices

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	var normals = PoolVector3Array()
	normals.append(Vector3.UP)
	normals.append(Vector3.UP)
	normals.append(Vector3.UP)
	normals.append(Vector3.UP)
	for _i in range(0, SIDES):
		normals.append(Vector3.UP)
	return normals

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	var tangents = PoolRealArray()
	tangents.append_array([1.0, 0.0, 0.0, 1.0])
	tangents.append_array([1.0, 0.0, 0.0, 1.0])
	tangents.append_array([1.0, 0.0, 0.0, 1.0])
	tangents.append_array([1.0, 0.0, 0.0, 1.0])
	for _i in range(0, SIDES):
		tangents.append_array([1.0, 0.0, 0.0, 1.0])
	return tangents

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	var verts = get_vertices()

	var uvs = PoolVector2Array()
	for vert in verts:
		uvs.append(Vector2(vert.x, vert.z) * uv_scale)
	return uvs

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	var uvs = get_uvs()
	var uv2s = PoolVector2Array()

	for uv in uvs:
		uv2s.append(uv * stud_density * Vector2(extents.x, extents.z) * 0.5)

	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	var indices = PoolIntArray()
	for side in range(0, SIDES - 1):
		var progress = (float(side) / float(SIDES - 1))
		var center_index = floor(progress * circ_factor * 4.0)
		if flip:
			indices.append_array([
				center_index, 
				3 + side + 1, 
				3 + side + 2
			])
		else :
			indices.append_array([
				3 + side + 2, 
				3 + side + 1, 
				center_index
			])
	return indices

func _init(in_radius:float, in_circ_factor:float, in_flip:bool = false, in_uv_scale = Vector2.ONE)->void :
	var scope = Profiler.scope(self, "_init", [in_radius, in_circ_factor, in_flip, in_uv_scale])

	radius = in_radius
	circ_factor = in_circ_factor
	flip = in_flip
	uv_scale = in_uv_scale
