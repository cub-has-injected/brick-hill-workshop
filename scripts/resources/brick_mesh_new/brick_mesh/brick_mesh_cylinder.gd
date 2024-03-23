class_name BrickMeshCylinder
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCircle.new(0.5, 1.0), 
		BrickFaceMeshCylinderWall.new(0.5, 1.0, false, 3.0), 
		BrickFaceMeshCircle.new(0.5, 1.0), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(), 
		Basis(), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180)))
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3.UP * 0.5, 
		Vector3.ZERO, 
		Vector3.DOWN * 0.5
	]

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray([
		"Top", 
		"Side", 
		"Bottom", 
	])

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	if normal.dot(Vector3.UP) > 0.5:
		return 0
	elif normal.dot(Vector3.DOWN) > 0.5:
		return 2

	return 1
