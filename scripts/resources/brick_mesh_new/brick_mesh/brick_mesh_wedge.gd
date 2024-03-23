class_name BrickMeshWedge
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshTriangle.new(
			PoolVector3Array([
				Vector3( - 1.0, 0.0, - 1.0) * 0.5, 
				Vector3(1.0, 0.0, 1.0) * 0.5, 
				Vector3( - 1.0, 0.0, 1.0) * 0.5
			]), 
			PoolVector2Array([
				Vector2(0.0, 0.0), 
				Vector2(1.0, 1.0), 
				Vector2(0.0, 1.0)
			])
		), 
		BrickFaceMeshTriangle.new(
			PoolVector3Array([
				Vector3(1.0, 0.0, - 1.0) * 0.5, 
				Vector3(1.0, 0.0, 1.0) * 0.5, 
				Vector3( - 1.0, 0.0, 1.0) * 0.5
			]), 
			PoolVector2Array([
				Vector2(1.0, 0.0), 
				Vector2(1.0, 1.0), 
				Vector2(0.0, 1.0)
			])
		), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshWedge.new(), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(Vector3(0, deg2rad(180), deg2rad(180))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(90))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad( - 90))), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad( - 90))), 
		Basis()
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3.DOWN * 0.5, 
		Vector3.LEFT * 0.5, 
		Vector3.RIGHT * 0.5, 
		Vector3.FORWARD * 0.5, 
		Vector3.ZERO
	]

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray([
		"Bottom", 
		"Left", 
		"Right", 
		"Forward", 
		"Top", 
	])

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	if normal.dot(Vector3.DOWN) > 0.999:
		return 0
	elif normal.dot(Vector3.LEFT) > 0.999:
		return 1
	elif normal.dot(Vector3.RIGHT) > 0.999:
		return 2
	elif normal.dot(Vector3.FORWARD) > 0.999:
		return 3

	return 4
