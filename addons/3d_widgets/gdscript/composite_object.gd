"\nRigidBody that can act as a Shape proxy for a set of other objects\n\nTargets must implement InterfaceSize, and InterfaceShapes\n"

class_name CompositeObject
extends RigidBody
tool 

signal rebuild_complete()

export (int, LAYERS_3D_PHYSICS) var temp_collision_layer
export (int, LAYERS_3D_PHYSICS) var temp_collision_mask

var _wants_update_aabb: = false
var _aabb:AABB

class CompositeData:
	var origin_offset:Vector3
	var basis_offset:Basis
	var collision_layer:int
	var collision_mask:int
	var input_ray_pickable:bool
	var shape_owners:PoolIntArray

	func _init(
		in_origin_offset:Vector3, 
		in_basis_offset:Basis, 
		in_collision_layer:int, 
		in_collision_mask:int, 
		in_input_ray_pickable:bool, 
		in_shape_owners:PoolIntArray
	)->void :
		origin_offset = in_origin_offset
		basis_offset = in_basis_offset
		collision_layer = in_collision_layer
		collision_mask = in_collision_mask
		input_ray_pickable = in_input_ray_pickable
		shape_owners = in_shape_owners

var _composite_data: = {}

func count()->int:
	return _composite_data.size()

func add_composite_data(node:Node)->void :
	var scope = Profiler.scope(self, "add_composite_data", [node])

	assert (is_instance_valid(node))

	var origin_offset = node.global_transform.origin - global_transform.origin
	var basis_offset = node.global_transform.basis * global_transform.basis.inverse()
	var collision_layer = - 1
	var collision_mask = - 1
	var input_ray_pickable = false

	if InterfaceCollisionLayer.is_implementor(node):
		collision_layer = InterfaceCollisionLayer.get_collision_layer(node)

	if InterfaceCollisionMask.is_implementor(node):
		collision_mask = InterfaceCollisionMask.get_collision_mask(node)

	if InterfaceInputRayPickable.is_implementor(node):
		input_ray_pickable = InterfaceInputRayPickable.get_input_ray_pickable(node)

	if InterfaceCollisionLayer.is_implementor(node):
		InterfaceCollisionLayer.set_collision_layer(node, temp_collision_layer)

	if InterfaceCollisionMask.is_implementor(node):
		InterfaceCollisionMask.set_collision_mask(node, temp_collision_mask)

	if InterfaceInputRayPickable.is_implementor(node):
		InterfaceInputRayPickable.set_input_ray_pickable(node, false)

	var shape_owners = PoolIntArray()
	if InterfaceShapes.is_implementor(node):
		var shapes = InterfaceShapes.get_shapes(node)
		var shapes_dict = shapes.get_shapes()
		for trx in shapes_dict:
			var owner = create_shape_owner(self)
			shape_owner_set_transform(owner, Transform(basis_offset, origin_offset) * trx)
			shape_owners.append(owner)
			for shape in shapes_dict[trx]:
				shape_owner_add_shape(owner, shape)

	var data = CompositeData.new(
		origin_offset, 
		basis_offset, 
		collision_layer, 
		collision_mask, 
		input_ray_pickable, 
		shape_owners
	)

	_composite_data[node] = data

	_wants_update_aabb = true

func remove_composite_data(node:Node)->void :
	var scope = Profiler.scope(self, "remove_composite_data", [node])

	assert (is_instance_valid(node))

	var data = _composite_data[node]

	if InterfaceCollisionLayer.is_implementor(node):
		InterfaceCollisionLayer.set_collision_layer(node, data.collision_layer)

	if InterfaceCollisionMask.is_implementor(node):
		InterfaceCollisionMask.set_collision_mask(node, data.collision_mask)

	if InterfaceInputRayPickable.is_implementor(node):
		InterfaceInputRayPickable.set_input_ray_pickable(node, data.input_ray_pickable)

	for owner in data.shape_owners:
		remove_shape_owner(owner)

	_composite_data.erase(node)

	if _composite_data.size() == 0:
		global_transform.basis = Basis.IDENTITY

	_wants_update_aabb = true

func update_composite_data(update_offsets:bool = false)->void :
	for node in _composite_data:
		var data = _composite_data[node]

		if update_offsets:
			data.origin_offset = node.global_transform.origin - global_transform.origin
			data.basis_offset = node.global_transform.basis * global_transform.basis.inverse()

		for owner in data.shape_owners:
			remove_shape_owner(owner)

		if InterfaceShapes.is_implementor(node):
			var shapes = InterfaceShapes.get_shapes(node)
			var shapes_dict = shapes.get_shapes()
			for trx in shapes_dict:
				var owner = create_shape_owner(self)
				shape_owner_set_transform(owner, Transform(data.basis_offset, data.origin_offset) * trx)
				data.shape_owners.append(owner)
				for shape in shapes_dict[trx]:
					shape_owner_add_shape(owner, shape)

	_wants_update_aabb = true

func update_aabb()->void :
	_aabb = get_local_aabb(_composite_data.keys())

	var delta = get_local_center()
	for node in _composite_data:
		var data = _composite_data[node]
		data.origin_offset -= delta
		for shape_owner in data.shape_owners:
			var trx = shape_owner_get_transform(shape_owner)
			trx.origin -= delta
			shape_owner_set_transform(shape_owner, trx)

	_aabb.position -= delta
	global_transform.origin += delta

	emit_signal("rebuild_complete")


func get_size()->Vector3:
	var scope = Profiler.scope(self, "get_size", [])

	return _aabb.size

func set_size(new_size:Vector3)->void :
	var scope = Profiler.scope(self, "set_size", [new_size])

	assert (false, "Can't set the size of a composite object")


func get_rigid_body()->RigidBody:
	var scope = Profiler.scope(self, "get_rigid_body", [])

	return self


func get_shapes()->InterfaceShapes.Shapes:
	var scope = Profiler.scope(self, "get_shapes", [])

	var shapes = InterfaceShapes.Shapes.new()

	for owner in get_shape_owners():
		var trx = global_transform * shape_owner_get_transform(owner)
		var count = shape_owner_get_shape_count(owner)
		for i in range(0, count):
			var shape = shape_owner_get_shape(owner, i)
			shapes.add_shape(trx, shape)

	return shapes


func get_local_center()->Vector3:
	var scope = Profiler.scope(self, "get_local_center", [])

	return _aabb.position + _aabb.size * 0.5


func get_group_origin()->Vector3:
	var scope = Profiler.scope(self, "get_group_origin", [])

	var targets = _composite_data.keys()
	if targets.size() != 1:
		return Vector3.ZERO

	var node = targets[0]
	if not node is BrickHillGroup:
		return Vector3.ZERO

	return node.origin


func get_local_aabb(targets:Array)->AABB:
	var scope = Profiler.scope(self, "get_local_aabb", [])

	var min_corner = Vector3.ZERO
	var max_corner = Vector3.ZERO
	var first = true

	for node in targets:
		if InterfaceLocalCenter.is_implementor(node) and InterfaceSize.is_implementor(node):
			var local = node.global_transform.origin - global_transform.origin
			var node_center = local + InterfaceLocalCenter.get_local_center(node)
			var node_local_size = InterfaceSize.get_size(node)
			var node_size:Vector3
			if targets.size() == 1:
				node_size = node_local_size
			else :
				var v0 = node.global_transform.basis.xform(node_local_size * Vector3(1.0, 1.0, 1.0) * 0.5)
				var v1 = node.global_transform.basis.xform(node_local_size * Vector3(1.0, - 1.0, 1.0) * 0.5)
				var v2 = node.global_transform.basis.xform(node_local_size * Vector3(1.0, 1.0, - 1.0) * 0.5)
				var v3 = node.global_transform.basis.xform(node_local_size * Vector3(1.0, - 1.0, - 1.0) * 0.5)

				var max_x = max(abs(v0.x), max(abs(v1.x), max(abs(v2.x), abs(v3.x))))
				var max_y = max(abs(v0.y), max(abs(v1.y), max(abs(v2.y), abs(v3.y))))
				var max_z = max(abs(v0.z), max(abs(v1.z), max(abs(v2.z), abs(v3.z))))

				node_size = Vector3(max_x, max_y, max_z) * 2.0

			if first:
				min_corner = node_center - node_size * 0.5
				max_corner = node_center + node_size * 0.5
				first = false
			else :
				var min_c = node_center - node_size * 0.5
				var max_c = node_center + node_size * 0.5
				min_corner = Vector3(min(min_corner.x, min_c.x), min(min_corner.y, min_c.y), min(min_corner.z, min_c.z))
				max_corner = Vector3(max(max_corner.x, max_c.x), max(max_corner.y, max_c.y), max(max_corner.z, max_c.z))

	return AABB(min_corner, max_corner - min_corner)

func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	global_transform.basis = Basis.IDENTITY

	for node in _composite_data.keys():
		remove_composite_data(node)

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if _wants_update_aabb:
		update_aabb()
		_wants_update_aabb = false

	$VisualOffset.transform.origin = Vector3.ZERO
	var targets = _composite_data.keys()
	if targets.size() == 1:
		if InterfaceGroupOrigin.is_implementor(targets[0]):
			var origin = InterfaceGroupOrigin.get_group_origin(targets[0])
			$VisualOffset.global_transform.origin = targets[0].global_transform.origin + targets[0].global_transform.basis.orthonormalized().xform(origin)
		else :
			$VisualOffset.transform.origin = get_local_center()
		$VisualOffset.global_transform.basis = targets[0].global_transform.basis
	else :
		$VisualOffset.transform.origin = get_local_center()
		$VisualOffset.global_transform.basis = Basis.IDENTITY

func _notification(what:int)->void :
	var scope = Profiler.scope(self, "_notification", [what])

	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			for node in _composite_data:
				if "locked" in node:
					if node.locked:
						continue

				var data = _composite_data[node]
				var trx = Transform(
					global_transform.basis * data.basis_offset, 
					global_transform.origin + data.origin_offset
				).orthonormalized()
				if node.global_transform != trx:
					node.global_transform = trx
