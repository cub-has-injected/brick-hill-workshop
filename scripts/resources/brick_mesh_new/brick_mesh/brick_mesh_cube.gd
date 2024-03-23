class_name BrickMeshCube
extends BrickMesh
tool 

func get_surface_meshes()->Array:
	var scope = Profiler.scope(self, "get_surface_meshes", [])

	return [
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
		BrickFaceMeshQuad.new(), 
	]

func get_surface_bases()->Array:
	var scope = Profiler.scope(self, "get_surface_bases", [])

	return [
		Basis(Vector3.ZERO), 
		Basis(Vector3(0, deg2rad(180), deg2rad(180))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad(90))), 
		Basis(Vector3(deg2rad(90), 0, deg2rad( - 90))), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad( - 90))), 
		Basis(Vector3(deg2rad(90), deg2rad(90), deg2rad(90)))
	]

func get_surface_origins()->Array:
	var scope = Profiler.scope(self, "get_surface_origins", [])

	return [
		Vector3.UP * 0.5, 
		Vector3.DOWN * 0.5, 
		Vector3.LEFT * 0.5, 
		Vector3.RIGHT * 0.5, 
		Vector3.FORWARD * 0.5, 
		Vector3.BACK * 0.5, 
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
