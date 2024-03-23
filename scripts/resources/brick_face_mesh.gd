class_name BrickFaceMesh
tool 

export (Transform) var transform:Transform setget set_transform
export (Vector3) var extents: = Vector3.ONE setget set_extents
export (float) var stud_density: = 2.0 setget set_stud_density


func set_extents(new_extents:Vector3)->void :
	var scope = Profiler.scope(self, "set_extents", [new_extents])

	if extents != new_extents:
		extents = new_extents

func set_stud_density(new_stud_density:float)->void :
	var scope = Profiler.scope(self, "set_stud_density", [new_stud_density])

	if stud_density != new_stud_density:
		stud_density = new_stud_density

func set_transform(new_transform:Transform)->void :
	var scope = Profiler.scope(self, "set_transform", [new_transform])

	if transform != new_transform:
		transform = new_transform


func get_vertices()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_vertices", [])

	return PoolVector3Array()

func get_normals()->PoolVector3Array:
	var scope = Profiler.scope(self, "get_normals", [])

	return PoolVector3Array()

func get_tangents()->PoolRealArray:
	var scope = Profiler.scope(self, "get_tangents", [])

	return PoolRealArray()

func get_uvs()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uvs", [])

	return PoolVector2Array()

func get_uv2s()->PoolVector2Array:
	var scope = Profiler.scope(self, "get_uv2s", [])

	return get_uvs()

func get_indices()->PoolIntArray:
	var scope = Profiler.scope(self, "get_indices", [])

	return PoolIntArray()
