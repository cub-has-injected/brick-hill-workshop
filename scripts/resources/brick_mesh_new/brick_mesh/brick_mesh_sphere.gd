class_name BrickMeshSphere
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshCubeSphere.new(0.0, 0.0), 
		BrickFaceMeshCubeSphere.new(0.0, 0.0), 
		BrickFaceMeshCubeSphere.new(0.0, 0.0), 
		BrickFaceMeshCubeSphere.new(0.0, 0.0), 
		BrickFaceMeshCubeSphere.new(0.0, 0.0), 
		BrickFaceMeshCubeSphere.new(0.0, 0.0), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(90))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad( - 90))), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad( - 90))), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad(90)))
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3.ZERO, 
		Vector3.ZERO, 
		Vector3.ZERO, 
		Vector3.ZERO, 
		Vector3.ZERO, 
		Vector3.ZERO
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
