class_name BrickMeshSphereEigth
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCubeSphere.new(true, true, Vector2(1.5, 1.5)), 
		BrickFaceMeshCircle.new(0.5, 0.25, false, Vector2(2, 2)), 
		BrickFaceMeshCubeSphere.new(true, true, Vector2(1.5, 1.5)), 
		BrickFaceMeshCircle.new(0.5, 0.25, false, Vector2(2, 2)), 
		BrickFaceMeshCircle.new(0.5, 0.25, false, Vector2(2, 2)), 
		BrickFaceMeshCubeSphere.new(true, true, Vector2(1.5, 1.5)), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(Vector3(0, deg2rad(180), 0)).scaled(Vector3.ONE * 2), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))).scaled(Vector3.ONE * 2), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(90))).scaled(Vector3.ONE * 2), 
		Basis(Vector3(deg2rad(90), 0, deg2rad( - 90))).scaled(Vector3.ONE * 2), 
		Basis(Vector3(deg2rad(0), deg2rad(90), deg2rad( - 90))).scaled(Vector3.ONE * 2), 
		Basis(Vector3(deg2rad(0), deg2rad(90), deg2rad(90))).scaled(Vector3.ONE * 2)
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


func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3(1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, - 1) * 0.5
	]
