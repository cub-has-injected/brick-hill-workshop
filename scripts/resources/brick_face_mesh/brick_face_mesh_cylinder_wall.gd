class_name BrickFaceMeshCylinderWall
extends BrickFaceMesh
tool 

const SIDES = 32

var radius: = 1.0
var circ_factor: = 1.0
var flip: = false
var uv_density = 6.0


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	var vertices = PoolVector3Array()
	for side in range(0, SIDES):
		var progress = float(side) / float(SIDES - 1)
		var forward = radius * Vector3.FORWARD.rotated(Vector3.UP, progress * TAU * circ_factor)
		vertices.append(forward + Vector3.UP * 0.5)
		vertices.append(forward + Vector3.DOWN * 0.5)
	return vertices

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	var normals = PoolVector3Array()
	var base_normal = Vector3.BACK if flip else Vector3.FORWARD
	for side in range(0, SIDES):
		var normal = base_normal.rotated(Vector3.UP, (float(side) / float(SIDES - 1)) * TAU * circ_factor)
		normals.append(normal)
		normals.append(normal)
	return normals

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	var tangents = PoolRealArray()
	var base_tangent = Vector3.RIGHT if flip else Vector3.LEFT
	for side in range(0, SIDES):
		var tangent = base_tangent.rotated(Vector3.UP, (float(side) / float(SIDES - 1)) * TAU * circ_factor)
		tangents.append_array([tangent.x, tangent.y, tangent.z, 1.0])
		tangents.append_array([tangent.x, tangent.y, tangent.z, 1.0])
	return tangents

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	var uvs = PoolVector2Array()
	for side in range(0, SIDES):
		var progress = (float(side) / float(SIDES - 1)) * circ_factor
		if flip:
			progress = circ_factor - progress
		uvs.append(Vector2(progress * uv_density, 0.0))
		uvs.append(Vector2(progress * uv_density, 1.0))
	return uvs

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	var uvs = get_uvs()
	var uv2s = PoolVector2Array()

	for uv in uvs:
		var uv2 = uv * stud_density * Vector2(max(extents.x, extents.z), extents.y) * 0.5
		uv2.x *= 0.5
		uv2s.append(uv2)

	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	var indices = PoolIntArray()
	var vert_count = SIDES * 2

	if flip:
		indices.append(3)
		indices.append(2)
		indices.append(1)
	else :
		indices.append(1)
		indices.append(2)
		indices.append(3)

	for side in range(0, vert_count - 4, 2):
		if flip:
			indices.append(side)
			indices.append(side + 1)
			indices.append(side + 2)

			indices.append(side + 5)
			indices.append(side + 4)
			indices.append(side + 3)
		else :
			indices.append(side + 2)
			indices.append(side + 1)
			indices.append(side)

			indices.append(side + 3)
			indices.append(side + 4)
			indices.append(side + 5)

	if flip:
		indices.append(vert_count - 4)
		indices.append(vert_count - 3)
		indices.append(vert_count - 2)
	else :
		indices.append(vert_count - 2)
		indices.append(vert_count - 3)
		indices.append(vert_count - 4)

	return indices

func _init(in_radius:float, in_circ_factor:float, in_flip:bool = false, in_uv_density = 6.0)->void :
	var scope = Profiler.scope(self, "_init", [in_radius, in_circ_factor, in_flip, in_uv_density])

	radius = in_radius
	circ_factor = in_circ_factor
	flip = in_flip
	uv_density = in_uv_density
