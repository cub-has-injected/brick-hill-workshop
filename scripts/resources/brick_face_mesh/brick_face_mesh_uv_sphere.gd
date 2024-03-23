class_name BrickFaceMeshUVSphere
extends BrickFaceMesh
tool 

const PARALLELS = 16
const MERIDIANS = 16
const HEMISPHERE = false
const HEIGHT = 2.0
const RADIUS = 1.0

var vertices: = PoolVector3Array()
var normals: = PoolVector3Array()
var tangents: = PoolRealArray()
var uvs: = PoolVector2Array()
var indices: = PoolIntArray()

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	var prevrow: = 0
	var thisrow: = 0
	var point: = 0

	for j in range(0, MERIDIANS + 2):
		var v = float(j) / float(MERIDIANS + 1)
		var w = sin(PI * v)
		var y = HEIGHT * (1.0 if HEMISPHERE else 0.5) * cos(PI * v)

		for i in range(0, PARALLELS + 1):
			var u = float(i);
			u /= PARALLELS;

			var x = sin(u * (PI * 2.0));
			var z = cos(u * (PI * 2.0));

			if HEMISPHERE and y < 0.0:
				vertices.append(Vector3(x * RADIUS * w, 0.0, z * RADIUS * w))
				normals.append(Vector3(0.0, - 1.0, 0.0))
			else :
				var p = Vector3(x * RADIUS * w, y, z * RADIUS * w)
				vertices.append(p);
				normals.append(p.normalized());

			tangents.append_array([z, 0.0, - x, 1.0])

			uvs.append(Vector2(u * 3.0, (0.25 + v) * 1.5));
			point += 1

			if i > 0 and j > 0:
				indices.append(prevrow + i - 1);
				indices.append(prevrow + i);
				indices.append(thisrow + i - 1);

				indices.append(prevrow + i);
				indices.append(thisrow + i);
				indices.append(thisrow + i - 1);

		prevrow = thisrow
		thisrow = point


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	var verts_mod = PoolVector3Array()
	for vert in vertices:
		verts_mod.append(vert)
	return verts_mod

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	return normals

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	return tangents

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	return uvs

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	var uv2s = PoolVector2Array()
	for uv in uvs:
		uv2s.append(uv * stud_density * extents.x)
	return uv2s

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	return indices
