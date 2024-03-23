class_name BrickMeshSphereHalf
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCubeSphere.new(false, false), 
		BrickFaceMeshCircle.new(0.5, 1.0), 
		BrickFaceMeshCubeSphere.new(false, true, Vector2(1, 2)), 
		BrickFaceMeshCubeSphere.new(false, true, Vector2(1, 2)), 
		BrickFaceMeshCubeSphere.new(false, true, Vector2(1, 2)), 
		BrickFaceMeshCubeSphere.new(false, true, Vector2(1, 2)), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis().scaled(Vector3(1, 2, 1)), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))).scaled(Vector3(1, 2, 1)), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(90))).scaled(Vector3(1, 2, 1)), 
		Basis(Vector3(deg2rad(90), 0, deg2rad( - 90))).scaled(Vector3(1, 2, 1)), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad( - 90))).scaled(Vector3(1, 2, 1)), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad(90))).scaled(Vector3(1, 2, 1))
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
		Vector3.DOWN * 0.5, 
		Vector3.DOWN * 0.5, 
		Vector3.DOWN * 0.5, 
		Vector3.DOWN * 0.5, 
		Vector3.DOWN * 0.5, 
		Vector3.DOWN * 0.5
	]
