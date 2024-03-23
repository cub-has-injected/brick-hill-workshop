class_name BoneTransform
extends Spatial
tool 

var bone:int = 0 setget set_bone

var _bone_name:String


func set_bone(new_bone:int)->void :
	if bone != new_bone:
		bone = new_bone
		update_bone_name()


func _get_property_list()->Array:
	var property_list: = []

	property_list.append({
		"name":"BoneTransform", 
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


func _ready()->void :
	update_bone()

func _process(_delta:float)->void :
	var skeleton = SkeletonUtil.get_skeleton_ancestor(self)
	if not skeleton:
		return 

	if bone <= 0:
		return 

	var bone_idx = bone - 1

	global_transform = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx)
