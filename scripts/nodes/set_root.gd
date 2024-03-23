class_name SetRoot
extends Spatial
tool 

signal spawn_points_changed(spawn_points)
signal primary_spawn_changed(index)


const PRINT: = false


var primary_spawn: = 0
var player_gravity_scale: = 1.2

var uuid: = ""


var _workshop: = false setget set_workshop
var _spawn_point_paths: = [] setget set_spawn_point_paths


func set_workshop(new_workshop:bool)->void :
	var scope = Profiler.scope(self, "set_workshop", [new_workshop])

	if _workshop != new_workshop:
		_workshop = new_workshop

func set_spawn_point_paths(new_spawn_point_paths:Array)->void :
	var scope = Profiler.scope(self, "set_spawn_point_paths", [new_spawn_point_paths])

	var candidates: = []
	for spawn_point in new_spawn_point_paths:
		if spawn_point is NodePath and not spawn_point.is_empty():
			candidates.append(spawn_point)

	if _spawn_point_paths != candidates:
		_spawn_point_paths = candidates

func _get_spawn_point_enum_string()->String:
	var scope = Profiler.scope(self, "_get_spawn_point_enum_string", [])

	if _spawn_point_paths.empty():
		return "[None]"

	var names = PoolStringArray(["[Random]"])
	for spawn_point_path in _spawn_point_paths:
		var spawn_point = get_node_or_null(spawn_point_path)
		if spawn_point:
			names.append(spawn_point.get_name())
	return names.join(",")

func get_tree_icon(highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon", [highlight])

	if highlight:
		return preload("res://ui/icons/workshop-assets/Parts/selectGroup.png")
	else :
		return preload("res://ui/icons/workshop-assets/Parts/Group.png")


func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	var spawn_point_names = []

	for path in _spawn_point_paths:
		spawn_point_names.append(path.get_name(path.get_name_count() - 1))

	if spawn_point_names.size() == 0:
		spawn_point_names = ["[Default]"]

	var spawn_point_name_string:String
	for name in spawn_point_names:
		spawn_point_name_string += name
		if name != spawn_point_names.back():
			spawn_point_name_string += ","

	return [
		{
			"name":"primary_spawn", 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_ENUM, 
			"hint_string":spawn_point_name_string, 
			"usage":PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		}, 
		{
			"name":"player_gravity_scale", 
			"type":TYPE_REAL, 
			"hint":PROPERTY_HINT_RANGE, 
			"hint_string":"0.01,10.0,0.01", 
			"usage":PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		}, 
		{
			"name":"uuid", 
			"type":TYPE_STRING, 
			"hint":PROPERTY_HINT_NONE, 
			"usage":PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
		}, 
	]

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	request_ready()

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	if uuid.empty():
		uuid = UUID.v4()

	if Engine.is_editor_hint():
		return 

	_spawn_point_paths_changed()
	_primary_spawn_changed()

	if not _workshop:
		begin_play()


func begin_play()->void :
	var scope = Profiler.scope(self, "begin_play", [])

	if PRINT:
		print_debug("%s begin play")
	setup_group_nodes()
	setup_glue_nodes()
	unfreeze_nodes()

func freeze_nodes()->void :
	var scope = Profiler.scope(self, "freeze_nodes", [])

	if PRINT:
		print_debug("%s freeze nodes" % [get_name()])
	BrickHillUtil.recursive_traverse(self, funcref(self, "freeze_node"))

func unfreeze_nodes()->void :
	var scope = Profiler.scope(self, "unfreeze_nodes", [])

	if PRINT:
		print_debug("%s unfreeze nodes" % [get_name()])
	BrickHillUtil.recursive_traverse(self, funcref(self, "unfreeze_node"))

func setup_group_nodes()->void :
	var scope = Profiler.scope(self, "setup_group_nodes", [])

	if PRINT:
		print_debug("%s setup group nodes" % [get_name()])
	BrickHillUtil.recursive_traverse(self, funcref(self, "setup_group_node"))

func setup_glue_nodes()->void :
	var scope = Profiler.scope(self, "setup_glue_nodes", [])

	if PRINT:
		print_debug("%s setup glue nodes" % [get_name()])
	BrickHillUtil.recursive_traverse(self, funcref(self, "setup_glue_node"))

func freeze_node(node:BrickHillPhysicsObject)->void :
	var scope = Profiler.scope(self, "freeze_node", [node])

	if PRINT:
		print_debug("%s freeze node %s" % [get_name(), node])

	if node:
		node.freeze()

func unfreeze_node(node:BrickHillObject)->void :
	var scope = Profiler.scope(self, "unfreeze_node", [node])

	if PRINT:
		print_debug("%s unfreeze node %s" % [get_name(), node])

	if node:
		node.unfreeze()

const BOX_POINTS: = PoolVector3Array([
		Vector3( - 1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, - 1) * 0.5, 
		Vector3(1, - 1, 1) * 0.5, 
		Vector3( - 1, - 1, 1) * 0.5, 

		Vector3( - 1, 1, - 1) * 0.5, 
		Vector3(1, 1, - 1) * 0.5, 
		Vector3(1, 1, 1) * 0.5, 
		Vector3( - 1, 1, 1) * 0.5
	])

const SPHERE_POINTS: = PoolVector3Array([
		Vector3.UP * 0.5, 
		Vector3.DOWN * 0.5, 
		Vector3.LEFT * 0.5, 
		Vector3.RIGHT * 0.5, 
		Vector3.FORWARD * 0.5, 
		Vector3.BACK * 0.5, 

		Vector3( - 1, - 1, - 1) * 0.25, 
		Vector3(1, - 1, - 1) * 0.25, 
		Vector3(1, - 1, 1) * 0.25, 
		Vector3( - 1, - 1, 1) * 0.25, 

		Vector3( - 1, 1, - 1) * 0.25, 
		Vector3(1, 1, - 1) * 0.25, 
		Vector3(1, 1, 1) * 0.25, 
		Vector3( - 1, 1, 1) * 0.25
	])

func setup_group_node(node:BrickHillGroup)->void :
	var scope = Profiler.scope(self, "setup_group_node", [node])

	if PRINT:
		print_debug("%s setup group node %s" % [get_name(), node])

	if not is_instance_valid(node):
		return 

	if node is BrickHillGlue:
		return 

	var group_parent = node.get_parent()

	var child_bricks: = []
	for child in node.get_children():
		if not child is BrickHillPhysicsObject:
			continue

		var cached_trx = child.global_transform
		child.anchored = node.anchored
		node.remove_child(child)
		group_parent.add_child(child)
		child.global_transform = cached_trx

	group_parent.remove_child(node)
	node.queue_free()

func setup_glue_node(node:BrickHillGlue)->void :
	var scope = Profiler.scope(self, "setup_glue_node", [node])

	if PRINT:
		print_debug("%s setup glue node %s" % [get_name(), node])

	if not is_instance_valid(node):
		return 

	var group_rb = node.get_rigid_body()

	var group_collision_shape = group_rb.get_node_or_null("CollisionShape")

	if node.merge_collisions:
		group_collision_shape.shape = ConvexPolygonShape.new()

	var child_bricks: = []
	for child in node.get_children():
		if not child is BrickHillPhysicsObject:
			continue

		if child is BrickHillGroup:
			continue

		child_bricks.append(child)

	if child_bricks.size() == 0:
		return 

	var composite_points = PoolVector3Array()
	for child_brick in child_bricks:
		child_brick.set_anchored(false)

		if node.merge_collisions:
			var convex = ModelManager.get_brick_shape(child_brick.shape, true)

			var convex_points
			if convex is ConvexPolygonShape:
				convex_points = convex.points
			elif convex is BoxShape:
				convex_points = BOX_POINTS
			elif convex is SphereShape:
				convex_points = SPHERE_POINTS
			else :
				assert (false, "Unhandled collision shape")

			var points = PoolVector3Array()

			for point in convex_points:
				point *= child_brick.size
				point = child_brick.transform.basis.orthonormalized().xform(point)
				point += child_brick.transform.origin
				composite_points.append(point)

		var rigid_body = child_brick.get_rigid_body()
		for rb_child in rigid_body.get_children():
			if "global_transform" in rb_child:
				if node.merge_collisions and rb_child is CollisionShape:
					continue

				var cached_transform = child_brick.global_transform
				var cached_rotation = child_brick.rotation_degrees
				var cached_scale = Vector3.ONE

				if "size" in child_brick:
					cached_scale = child_brick.size

				rigid_body.remove_child(rb_child)
				group_rb.add_child(rb_child)

				call_deferred("fixup_transform", rb_child, cached_transform, cached_rotation, cached_scale)

		node.remove_child(child_brick)
		child_brick.queue_free()

	if node.merge_collisions:
		group_collision_shape.shape.points = composite_points

func fixup_transform(node:Node, transform:Transform, rotation:Vector3, scale:Vector3):
	var scope = Profiler.scope(self, "fixup_transform", [node, transform, rotation, scale])

	node.global_transform = transform
	node.rotation_degrees = rotation
	node.scale = scale

	if node is PhysicsInterpolator:
		var parent = node.get_parent()
		for child in node.get_children():
			node.remove_child(child)
			parent.add_child(child)

			call_deferred("fixup_transform", child, transform, rotation, scale)

func _spawn_point_paths_changed()->void :
	var scope = Profiler.scope(self, "_spawn_point_paths_changed", [])

	emit_signal("spawn_points_changed", _spawn_point_paths)

func _primary_spawn_changed()->void :
	var scope = Profiler.scope(self, "_primary_spawn_changed", [])

	emit_signal("primary_spawn_changed", primary_spawn)

func register_spawn_point(spawn_point:Node)->void :
	var scope = Profiler.scope(self, "register_spawn_point", [spawn_point])

	var spawn_point_path = get_path_to(spawn_point)
	if not spawn_point_path in _spawn_point_paths:
		_spawn_point_paths.append(spawn_point_path)
		_spawn_point_paths_changed()

func unregister_spawn_point(spawn_point:Node)->void :
	var scope = Profiler.scope(self, "unregister_spawn_point", [spawn_point])

	var spawn_point_path = get_path_to(spawn_point)
	if spawn_point_path in _spawn_point_paths:
		_spawn_point_paths.erase(spawn_point_path)
		_spawn_point_paths_changed()

func get_spawn_point(index:int)->Node:
	var scope = Profiler.scope(self, "get_spawn_point", [index])

	return get_node_or_null(_spawn_point_paths[index])

func set_primary_spawn(new_primary_spawn:int)->void :
	var scope = Profiler.scope(self, "set_primary_spawn", [new_primary_spawn])

	if primary_spawn != new_primary_spawn:
		primary_spawn = new_primary_spawn
		_primary_spawn_changed()

func get_workshop_spawn_point()->Node:
	var scope = Profiler.scope(self, "get_workshop_spawn_point", [])

	if _spawn_point_paths.size() == 0:
		return null

	if primary_spawn == 0:
		return get_spawn_point(randi() % _spawn_point_paths.size())

	return get_spawn_point(primary_spawn - 1)

func get_blacklist_paths()->Array:
	var scope = Profiler.scope(self, "get_blacklist_paths", [])

	return [
		":Spatial:Transform:translation", 
		":Spatial:Transform:rotation_degrees", 
		":Script Variables::uuid", 
	]
