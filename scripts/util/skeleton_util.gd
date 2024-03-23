class_name SkeletonUtil

static func get_bone_list(skeleton:Skeleton)->PoolStringArray:
	var bone_list = PoolStringArray(["[None]"])
	if skeleton:
		var bone_count = skeleton.get_bone_count()
		for i in range(0, bone_count):
			bone_list.append(skeleton.get_bone_name(i))
	return bone_list

static func get_skeleton_ancestor(node:Node)->Skeleton:
	var candidate = node
	var skeleton = null
	while true:
		var parent = candidate.get_parent()
		if not parent:
			break
		if parent is Skeleton:
			skeleton = parent
			break
		candidate = parent
	return skeleton
