class_name BrickMeshCylinderQuarter
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCircle.new(1.0, 0.25), 
		BrickFaceMeshCylinderWall.new(1.0, 0.25), 
		BrickFaceMeshCircle.new(1.0, 0.25), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(), 
		Basis(), 
		Basis(Vector3(0, deg2rad(90), deg2rad(180))), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad(0))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(0))), 
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3(1, 0, 1) * 0.5 + Vector3.UP * 0.5, 
		Vector3(1, 0, 1) * 0.5 + Vector3.ZERO, 
		Vector3(1, 0, 1) * 0.5 + Vector3.DOWN * 0.5, 
		Vector3.RIGHT * 0.5, 
		Vector3.BACK * 0.5
	]

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray([
		"Top", 
		"Left", 
		"Bottom", 
		"Right", 
		"Back", 
	])

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	if normal.dot(Vector3.UP) > 0.5:
		return 0
	elif normal.dot(Vector3.DOWN) > 0.5:
		return 2
	elif normal.dot(Vector3.RIGHT) > 0.5:
		return 3
	elif normal.dot(Vector3.BACK) > 0.5:
		return 4

	return 1
