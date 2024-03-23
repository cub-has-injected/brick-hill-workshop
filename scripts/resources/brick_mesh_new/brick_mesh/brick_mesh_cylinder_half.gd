class_name BrickMeshCylinderHalf
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCircle.new(0.5, 0.5, false, Vector2(2.0, 1.0)), 
		BrickFaceMeshCylinderWall.new(0.5, 0.5), 
		BrickFaceMeshCircle.new(0.5, 0.5, false, Vector2(2.0, 1.0)), 
		BrickFaceMeshQuad.new(), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis().scaled(Vector3(2, 1, 1)), 
		Basis().scaled(Vector3(2, 1, 1)), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))).scaled(Vector3(2, 1, 1)), 
		Basis(Vector3(deg2rad(90), deg2rad(90), 0)), 
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3.RIGHT * 0.5 + Vector3.UP * 0.5, 
		Vector3.RIGHT * 0.5 + Vector3.ZERO, 
		Vector3.RIGHT * 0.5 + Vector3.DOWN * 0.5, 
		Vector3.RIGHT * 0.5
	]

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray([
		"Top", 
		"Left", 
		"Bottom", 
		"Right", 
	])

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	if normal.dot(Vector3.UP) > 0.5:
		return 0
	elif normal.dot(Vector3.DOWN) > 0.5:
		return 2
	elif normal.dot(Vector3.RIGHT) > 0.5:
		return 3

	return 1
