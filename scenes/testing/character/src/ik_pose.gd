class_name IKPose
extends Position3D
tool 

enum Mode{OneAxis, TwoAxis}
enum Axis{X, Y, Z}

var bone:int = 0 setget set_bone
var mode = Mode.TwoAxis setget set_mode
var axis:int = Axis.X
var out_axis:int = Axis.X
var flip_axis: = false

var _bone_name:String
var _immediate_geometry:ImmediateGeometry


func set_bone(new_bone:int)->void :
	if bone != new_bone:
		if bone > 0:
			reset_bone_pose(bone)
		bone = new_bone
		update_bone_name()

func set_mode(new_mode:int)->void :
	if mode != new_mode:
		mode = new_mode
		property_list_changed_notify()


func _get_property_list()->Array:
	var property_list: = []

	property_list.append({
		"name":"IK Pose", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_CATEGORY
	})

	property_list.append({
		"name":"bone", 
		"type":TYPE_INT, 
		"hint":PROPERTY_HINT_ENUM, 
		"hint_string":SkeletonUtil.get_bone_list(SkeletonUtil.get_skeleton_ancestor(self)).join(",")
	})

	property_list.append({
		"name":"mode", 
		"type":TYPE_INT, 
		"hint":PROPERTY_HINT_ENUM, 
		"hint_string":PoolStringArray(Mode.keys()).join(",")
	})

	property_list.append({
		"name":"axis", 
		"type":TYPE_INT, 
		"hint":PROPERTY_HINT_ENUM, 
		"hint_string":PoolStringArray(Axis.keys()).join(",")
	})

	if mode == Mode.OneAxis:
		property_list.append({
			"name":"out_axis", 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_ENUM, 
			"hint_string":PoolStringArray(Axis.keys()).join(",")
		})

	property_list.append({
		"name":"flip_axis", 
		"type":TYPE_BOOL
	})

	property_list.append({
		"name":"_bone_name", 
		"type":TYPE_STRING, 
		"usage":PROPERTY_USAGE_NOEDITOR
	})

	return property_list


func update_bone_name()->void :
	var bone_list = SkeletonUtil.get_bone_list(SkeletonUtil.get_skeleton_ancestor(self))
	if bone >= 0 and bone < bone_list.size():
		_bone_name = bone_list[bone]
	else :
		_bone_name = ""

func update_bone()->void :
	bone = Array(SkeletonUtil.get_bone_list(SkeletonUtil.get_skeleton_ancestor(self))).find(_bone_name)
	if bone == - 1:
		bone = 0


func _enter_tree()->void :
	for child in get_children():
		if child.has_meta("ik_pose_child"):
			remove_child(child)
			child.queue_free()

	var mat: = SpatialMaterial.new()
	mat.vertex_color_use_as_albedo = true
	mat.flags_unshaded = true
	mat.flags_no_depth_test = true

	_immediate_geometry = ImmediateGeometry.new()
	_immediate_geometry.material_override = mat

	_immediate_geometry.set_meta("ik_pose_child", true)
	add_child(_immediate_geometry)

func _ready()->void :
	update_bone()

func _process(_delta:float)->void :
	
	clear_debug()

	var skeleton = SkeletonUtil.get_skeleton_ancestor(self)
	if not skeleton:
		return 

	if bone <= 0:
		return 

	var bone_idx = bone - 1

	var global_rest = calculate_global_rest(skeleton, bone_idx)

	
	draw_debug(skeleton, bone_idx, global_rest)

	update_ik(skeleton, bone_idx, global_rest)


func calculate_global_rest(skeleton:Skeleton, bone_idx:int)->Transform:
	var candidate = bone_idx
	var global_rest = skeleton.get_bone_rest(bone_idx)
	while true:
		var parent = skeleton.get_bone_parent(candidate)
		if parent == - 1:
			break
		global_rest = skeleton.get_bone_rest(parent) * global_rest
		candidate = parent
	return global_rest

func update_ik(skeleton:Skeleton, bone_idx:int, global_rest:Transform)->void :
	var local_transform = skeleton.global_transform.inverse() * global_transform

	var trx = Transform()
	match mode:
		Mode.TwoAxis:
			var target_point = Vector3.ZERO
			match axis:
				Axis.X:
					target_point = global_rest.basis.x
				Axis.Y:
					target_point = global_rest.basis.y
				Axis.Z:
					target_point = global_rest.basis.z

			if flip_axis:
				target_point *= - 1.0

			trx = global_rest.looking_at(local_transform.origin, target_point)
		Mode.OneAxis:
			var d = local_transform.origin - global_rest.origin
			var a = Vector3.ZERO
			match out_axis:
				Axis.X:
					a = global_rest.basis.x
				Axis.Y:
					a = global_rest.basis.y
				Axis.Z:
					a = global_rest.basis.z

			if flip_axis:
				a *= - 1.0

			var out_angle = 0.0
			match axis:
				Axis.X:
					out_angle = atan2(d.y, d.z)
				Axis.Y:
					out_angle = atan2(d.x, d.z)
				Axis.Z:
					out_angle = atan2(d.x, d.y)

			trx = global_rest.rotated(a, out_angle)

	trx = Transform(trx.basis, Vector3.ZERO)
	skeleton.set_bone_custom_pose(bone_idx, Transform(global_rest.inverse().basis, Vector3.ZERO) * trx)

func reset_bone_pose(bone_idx:int)->void :
	var skeleton = SkeletonUtil.get_skeleton_ancestor(self)
	if not skeleton:
		return 

	skeleton.set_bone_custom_pose(bone_idx - 1, Transform())

func clear_debug()->void :
	_immediate_geometry.clear()

func draw_debug(skeleton:Skeleton, bone_idx:int, global_rest:Transform)->void :
	if not _immediate_geometry:
		return 

	_immediate_geometry.begin(Mesh.PRIMITIVE_LINES)

	var local_transform = skeleton.global_transform.inverse() * global_transform
	var origin = global_rest.origin - local_transform.origin

	_immediate_geometry.set_color(Color.white)
	_immediate_geometry.add_vertex(Vector3.ZERO)
	_immediate_geometry.add_vertex(origin)

	_immediate_geometry.set_color(Color.red)
	_immediate_geometry.add_vertex(origin)
	_immediate_geometry.add_vertex(origin + global_rest.basis.x * 0.25)

	_immediate_geometry.set_color(Color.green)
	_immediate_geometry.add_vertex(origin)
	_immediate_geometry.add_vertex(origin + global_rest.basis.y * 0.25)

	_immediate_geometry.set_color(Color.blue)
	_immediate_geometry.add_vertex(origin)
	_immediate_geometry.add_vertex(origin + global_rest.basis.z * 0.25)

	var bone_global_pose = skeleton.get_bone_global_pose(bone_idx)

	_immediate_geometry.set_color(Color.cyan)
	_immediate_geometry.add_vertex(origin)
	_immediate_geometry.add_vertex(origin + bone_global_pose.basis.x * 0.25)

	_immediate_geometry.set_color(Color.magenta)
	_immediate_geometry.add_vertex(origin)
	_immediate_geometry.add_vertex(origin + bone_global_pose.basis.y * 0.25)

	_immediate_geometry.set_color(Color.yellow)
	_immediate_geometry.add_vertex(origin)
	_immediate_geometry.add_vertex(origin + bone_global_pose.basis.z * 0.25)

	_immediate_geometry.end()
