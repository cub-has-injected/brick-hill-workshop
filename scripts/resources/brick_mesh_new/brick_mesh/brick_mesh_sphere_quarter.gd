class_name BrickMeshSphereQuarter
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCubeSphere.new(true, false, Vector2(1.4, 1)), 
		BrickFaceMeshCircle.new(0.5, 0.5, false, Vector2(2, 1)), 
		BrickFaceMeshCubeSphere.new(false, true, Vector2(1, 1.4)), 
		BrickFaceMeshCircle.new(0.5, 0.5, false, Vector2(2, 1)), 
		BrickFaceMeshCubeSphere.new(true, true, Vector2(1.4, 1.4)), 
		BrickFaceMeshCubeSphere.new(true, true, Vector2(1.4, 1.4)), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(Vector3(0, deg2rad(180), 0)).scaled(Vector3(2, 2, 1)), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))).scaled(Vector3(2, 2, 1)), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(90))).scaled(Vector3(2, 2, 1)), 
		Basis(Vector3(0, 0, deg2rad( - 90))).scaled(Vector3(2, 2, 1)), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad( - 90))).scaled(Vector3(2, 2, 1)), 
		Basis(Vector3(deg2rad(0), deg2rad(90), deg2rad(90))).scaled(Vector3(2, 2, 1))
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3(1, - 1, 0) * 0.5, 
		Vector3(1, - 1, 0) * 0.5, 
		Vector3(1, - 1, 0) * 0.5, 
		Vector3(1, - 1, 0) * 0.5, 
		Vector3(1, - 1, 0) * 0.5, 
		Vector3(1, - 1, 0) * 0.5
	]

func get_surface_names()->PoolStringArray:
	var scope = Profiler.scope(self, "get_surface_names", [])

	return PoolStringArray([
		"Top", 
		"Bottom", 
		"Left", 
		"Right", 
		"Front", 
		"Back", 
	])
