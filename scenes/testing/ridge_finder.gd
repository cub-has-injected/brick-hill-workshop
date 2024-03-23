extends Spatial
tool 

const DEBUG = true;

export (Vector3) var from = Vector3.BACK
export (Vector3) var to = Vector3.FORWARD
export (Vector3) var normal = Vector3.UP
export (float) var distance = 2.0
export (int) var max_iterations = 40
export (float) var epsilon = 0.001

func _physics_process(_delta:float)->void :
	var frame_data = PhysicsUtil.FrameData.new()
	var result = PhysicsUtil.find_ridge(
		frame_data, 
		Color.red, 
		get_world().direct_space_state, 
		global_transform.origin + global_transform.basis.xform(from), 
		global_transform.origin + global_transform.basis.xform(to), 
		[self], 
		1, 
		global_transform.basis.xform(normal), 
		distance, 
		max_iterations, 
		epsilon
	)

	var immediate_geometry = $Node / ImmediateGeometry as ImmediateGeometry
	immediate_geometry.clear()
	immediate_geometry.begin(Mesh.PRIMITIVE_LINES)
	frame_data.debug_draw(immediate_geometry)
	immediate_geometry.end()

func get_color()->Color:
	return Color.red
