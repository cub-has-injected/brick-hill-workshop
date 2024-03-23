class_name BrickMeshInverseCylinderHalf
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCircle.new(0.5, 0.5, true, Vector2(2.0, 1.0)), 
		BrickFaceMeshCylinderWall.new(0.5, 0.5, true), 
		BrickFaceMeshCircle.new(0.5, 0.5, true, Vector2(2.0, 1.0)), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis().scaled(Vector3(2, 1, 1)), 
		Basis().scaled(Vector3(2, 1, 1)), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))).scaled(Vector3(2, 1, 1)), 
		Basis(Vector3(deg2rad(90), deg2rad( - 90), 0)), 
		Basis(Vector3(deg2rad(90), deg2rad(180), 0)), 
		Basis(Vector3(deg2rad(90), deg2rad(0), 0)), 
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3.RIGHT * 0.5 + Vector3.UP * 0.5, 
		Vector3.RIGHT * 0.5, 
		Vector3.RIGHT * 0.5 + Vector3.DOWN * 0.5, 
		Vector3.LEFT * 0.5, 
		Vector3.FORWARD * 0.5, 
		Vector3.BACK * 0.5, 
	]

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray([
		"Top", 
		"Right", 
		"Bottom", 
		"Left", 
		"Front", 
		"Back", 
	])

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	if normal.dot(Vector3.UP) > 0.999:
		return 0
	elif normal.dot(Vector3.DOWN) > 0.999:
		return 2
	elif normal.dot(Vector3.LEFT) > 0.999:
		return 3
	elif normal.dot(Vector3.FORWARD) > 0.999:
		return 4
	elif normal.dot(Vector3.BACK) > 0.999:
		return 5

	return 1
