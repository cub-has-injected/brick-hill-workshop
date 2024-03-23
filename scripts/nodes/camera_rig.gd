class_name CameraRig
extends Spatial
tool 

const EPSILON = 1e-05

enum RotationMode{
	PlayerController, 
	LookTarget
}

enum ProjectionMode{
	Perspective, 
	Orthogonal
}

var position_target_path

var rotation_mode:int = RotationMode.PlayerController setget set_rotation_mode
var look_target_path

var projection_mode:int = ProjectionMode.Perspective setget set_projection_mode
var perspective_fov:float = 70.0 setget set_perspective_fov
var orthogonal_size:float = 1.0 setget set_orthogonal_size

var local_offset: = Vector3.ZERO
var world_offset: = Vector3.ZERO

var use_position_spring: = true setget set_use_position_spring
var position_spring_length_lateral = 1.5
var position_spring_length_vertical = 2.0
var position_spring_tightness = 5.0

var target_distance: = 12.0

var use_distance_spring: = true setget set_use_distance_spring
var distance_spring_tightness: = 5.0
var distance_spring_radius: = 0.25

var _look_rotation: = Vector2.ZERO setget set_look_rotation
var _target_arm_dist: = 0.0

var _camera_shape:SphereShape


func set_look_rotation(new_look_rotation:Vector2)->void :
	var scope = Profiler.scope(self, "set_look_rotation", [new_look_rotation])

	if _look_rotation != new_look_rotation:
		_look_rotation = new_look_rotation

func set_rotation_mode(new_rotation_mode:int)->void :
	var scope = Profiler.scope(self, "set_rotation_mode", [new_rotation_mode])

	if rotation_mode != new_rotation_mode:
		rotation_mode = new_rotation_mode
		property_list_changed_notify()

func set_projection_mode(new_projection_mode:int)->void :
	var scope = Profiler.scope(self, "set_projection_mode", [new_projection_mode])

	if projection_mode != new_projection_mode:
		projection_mode = new_projection_mode

		if is_inside_tree():
			update_camera_projection_mode()

		property_list_changed_notify()

func set_perspective_fov(new_perspective_fov:float)->void :
	var scope = Profiler.scope(self, "set_perspective_fov", [new_perspective_fov])

	if perspective_fov != new_perspective_fov:
		perspective_fov = new_perspective_fov

		if is_inside_tree():
			update_camera_perspective_fov()

func set_orthogonal_size(new_orthogonal_size:float)->void :
	var scope = Profiler.scope(self, "set_orthogonal_size", [new_orthogonal_size])

	if orthogonal_size != new_orthogonal_size:
		orthogonal_size = new_orthogonal_size

		if is_inside_tree():
			update_camera_orthogonal_size()

func set_use_position_spring(new_use_position_spring:bool)->void :
	var scope = Profiler.scope(self, "set_use_position_spring", [new_use_position_spring])

	if use_position_spring != new_use_position_spring:
		use_position_spring = new_use_position_spring
		property_list_changed_notify()

func set_use_distance_spring(new_use_distance_spring:bool)->void :
	var scope = Profiler.scope(self, "set_use_distance_spring", [new_use_distance_spring])

	if use_distance_spring != new_use_distance_spring:
		use_distance_spring = new_use_distance_spring
		property_list_changed_notify()


func get_position_target()->Node:
	var scope = Profiler.scope(self, "get_position_target", [])

	return get_node(position_target_path)

func get_target_transform()->Transform:
	var scope = Profiler.scope(self, "get_target_transform", [])

	var position_target: = get_position_target()
	assert (position_target)

	var target_transform:Transform
	if position_target.has_method("get_camera_target_transform"):
		target_transform = position_target.get_camera_target_transform()
	else :
		target_transform = position_target.global_transform

	return target_transform

func get_camera_yaw()->Spatial:
	var scope = Profiler.scope(self, "get_camera_yaw", [])

	return $CameraYaw as Spatial

func get_camera_pitch()->Spatial:
	var scope = Profiler.scope(self, "get_camera_pitch", [])

	return $CameraYaw / CameraPitch as Spatial

func get_camera()->Camera:
	var scope = Profiler.scope(self, "get_camera", [])

	return $CameraYaw / CameraPitch / Camera as Camera


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	_target_arm_dist = target_distance
	_camera_shape = SphereShape.new()
	_camera_shape.radius = distance_spring_radius

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_camera_projection_mode()
	update_camera_perspective_fov()
	update_camera_orthogonal_size()

func update_camera_projection_mode()->void :
	var scope = Profiler.scope(self, "update_camera_projection_mode", [])

	var camera = get_camera()
	assert (camera)
	match projection_mode:
		ProjectionMode.Perspective:
			camera.projection = Camera.PROJECTION_PERSPECTIVE
		ProjectionMode.Orthogonal:
			camera.projection = Camera.PROJECTION_ORTHOGONAL

func update_camera_perspective_fov()->void :
	var scope = Profiler.scope(self, "update_camera_perspective_fov", [])

	var camera = get_camera()
	assert (camera)
	camera.fov = perspective_fov

func update_camera_orthogonal_size()->void :
	var scope = Profiler.scope(self, "update_camera_orthogonal_size", [])

	var camera = get_camera()
	assert (camera)
	camera.size = orthogonal_size

func _physics_process(delta:float)->void :
	var scope = Profiler.scope(self, "_physics_process", [delta])

	if Engine.is_editor_hint():
		return 

	var target_transform = get_target_transform()

	
	var direct_space_state = get_world().direct_space_state
	assert (direct_space_state)

	_target_arm_dist = target_distance

	
	if use_distance_spring:
		var basis = get_camera().global_transform.basis

		var trace_query = PhysicsShapeQueryParameters.new()
		var trace_trx = Transform.IDENTITY
		trace_trx.origin = global_transform.origin
		trace_query.transform = trace_trx
		trace_query.set_shape(_camera_shape)
		trace_query.collision_mask = 1
		trace_query.collide_with_bodies = true
		trace_query.collide_with_areas = false
		trace_query.exclude = [get_parent()]

		var trace_result = direct_space_state.cast_motion(trace_query, basis.z * target_distance)
		if not trace_result.empty() and not trace_result[0] == 1.0:
			if trace_result[0] * target_distance < _target_arm_dist:
				_target_arm_dist = trace_result[0] * target_distance

			var camera = get_camera()
			assert (camera)
			if camera.transform.origin.z > _target_arm_dist:
				camera.transform.origin.z = min(camera.transform.origin.z, _target_arm_dist)

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if Engine.is_editor_hint():
		return 

	
	var camera_yaw = get_camera_yaw()
	assert (camera_yaw)
	var camera_pitch = get_camera_pitch()
	assert (camera_pitch)

	match rotation_mode:
		RotationMode.PlayerController:
			var basis = Basis.IDENTITY
			basis = basis.rotated(Vector3.UP, _look_rotation.x)
			basis = basis.rotated(basis.x, _look_rotation.y)
			global_transform.basis = basis
		RotationMode.LookTarget:
			var look_target: = get_node(look_target_path)
			assert (look_target)
			var trx = Transform.IDENTITY.looking_at(look_target.global_transform.origin - global_transform.origin, Vector3.UP)
			global_transform.basis = trx.basis

	
	var target_transform = get_target_transform()

	target_transform = target_transform.translated(local_offset.rotated(Vector3.UP, _look_rotation.x - (global_transform.basis.get_euler().y - transform.basis.get_euler().y)))
	target_transform.origin += world_offset

	if use_position_spring:
		var dist = global_transform.origin - target_transform.origin
		var dist_lateral = dist
		dist_lateral.y = 0.0
		var dist_vertical = dist.y

		if dist_lateral.length() > position_spring_length_lateral:
			var new_origin_lateral = target_transform.origin + dist_lateral.normalized() * (position_spring_length_lateral - EPSILON)
			global_transform.origin.x = new_origin_lateral.x
			global_transform.origin.z = new_origin_lateral.z
		else :
			var lateral_origin = global_transform.origin
			lateral_origin.y = 0
			lateral_origin = lateral_origin.linear_interpolate(target_transform.origin, position_spring_tightness * delta)
			global_transform.origin.x = lateral_origin.x
			global_transform.origin.z = lateral_origin.z

		if dist_vertical > position_spring_length_vertical:
			global_transform.origin.y = target_transform.origin.y + sign(dist_vertical) * (position_spring_length_vertical - EPSILON)
		else :
			global_transform.origin.y = lerp(global_transform.origin.y, target_transform.origin.y, position_spring_tightness * delta)
	else :
		global_transform.origin = target_transform.origin

	
	var camera = get_camera()
	assert (camera)
	camera.transform.origin.z = lerp(camera.transform.origin.z, _target_arm_dist, delta * distance_spring_tightness)

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	var property_list: = []

	property_list.append({
		"name":"CameraRig", 
		"type":TYPE_NIL, 
		"usage":PROPERTY_USAGE_CATEGORY
	})

	property_list.append({
		"name":"Position", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_GROUP
	})

	property_list.append({
		"name":"position_target_path", 
		"type":TYPE_NODE_PATH
	})

	property_list.append({
		"name":"local_offset", 
		"type":TYPE_VECTOR3, 
	})

	property_list.append({
		"name":"world_offset", 
		"type":TYPE_VECTOR3, 
	})

	property_list.append({
		"name":"use_position_spring", 
		"type":TYPE_BOOL, 
	})

	if use_position_spring:
		property_list.append({
			"name":"Position/Spring", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_GROUP
		})

		property_list.append({
			"name":"position_spring_length_lateral", 
			"type":TYPE_REAL, 
		})

		property_list.append({
			"name":"position_spring_length_vertical", 
			"type":TYPE_REAL, 
		})

		property_list.append({
			"name":"position_spring_tightness", 
			"type":TYPE_REAL, 
		})

	property_list.append({
		"name":"Rotation", 
		"type":TYPE_NIL, 
		"usage":PROPERTY_USAGE_GROUP
	})

	property_list.append({
		"name":"rotation_mode", 
		"type":TYPE_INT, 
		"hint":PROPERTY_HINT_ENUM, 
		"hint_string":PoolStringArray(RotationMode.keys()).join(",")
	})

	if rotation_mode == RotationMode.LookTarget:
		property_list.append({
			"name":"look_target_path", 
			"type":TYPE_NODE_PATH, 
		})

	property_list.append({
		"name":"Projection", 
		"type":TYPE_NIL, 
		"usage":PROPERTY_USAGE_GROUP
	})

	property_list.append({
		"name":"projection_mode", 
		"type":TYPE_INT, 
		"hint":PROPERTY_HINT_ENUM, 
		"hint_string":PoolStringArray(ProjectionMode.keys()).join(",")
	})

	match projection_mode:
		ProjectionMode.Perspective:
			property_list.append({
				"name":"perspective_fov", 
				"type":TYPE_REAL, 
			})
		ProjectionMode.Orthogonal:
			property_list.append({
				"name":"orthogonal_size", 
				"type":TYPE_REAL, 
			})

	property_list.append({
		"name":"Distance", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_GROUP
	})

	property_list.append({
		"name":"target_distance", 
		"type":TYPE_REAL, 
	})

	property_list.append({
		"name":"use_distance_spring", 
		"type":TYPE_BOOL, 
	})

	property_list.append({
		"name":"Distance/Spring", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_GROUP
	})

	property_list.append({
		"name":"distance_spring_tightness", 
		"type":TYPE_REAL, 
	})

	property_list.append({
		"name":"distance_spring_radius", 
		"type":TYPE_REAL, 
	})

	return property_list
