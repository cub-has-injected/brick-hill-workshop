"\nSpatial that can move and rotate a target object relative to itself while respecting collision\n\nTarget objects must implement InterfaceSize, InterfaceRigidBody, and InterfaceShapes\n"

class_name MovementProxy
extends Spatial
tool 

signal moved(delta)
signal rotated(delta)

export (NodePath) var target setget set_target
export (bool) var check_collision: = true
export (bool) var continuous_collision: = true
export (int, LAYERS_3D_PHYSICS) var collision_mask = 0
export (Vector3) var origin: = Vector3.ZERO setget set_origin

const STEP_HYSTERESIS = 0.01

var _relative_transform: = Transform.IDENTITY

func set_target(new_target:NodePath)->void :
	var scope = Profiler.scope(self, "set_target", [new_target])

	if target != new_target:
		target = new_target
		target_changed()

func set_check_collision(new_check_collision:bool)->void :
	var scope = Profiler.scope(self, "set_check_collision", [new_check_collision])

	if check_collision != new_check_collision:
		check_collision = new_check_collision

func set_origin(new_origin:Vector3)->void :
	var scope = Profiler.scope(self, "set_origin", [new_origin])

	if origin != new_origin:
		origin = new_origin
		if is_inside_tree():
			update_origin()

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	if not get_node_or_null(target):
		return 
	update_origin()

func target_changed()->void :
	var scope = Profiler.scope(self, "target_changed", [])

	if is_inside_tree():
		var node = get_node_or_null(target)
		assert (node != null, "Invalid target")
		assert (InterfaceSize.is_implementor(node), "MovementProxy targets must implement InterfaceSize")
		assert (InterfaceShapes.is_implementor(node), "MovementProxy targets must implement InterfaceShapes")

		global_transform.basis = node.global_transform.basis
		update_origin()

func update_origin()->void :
	var scope = Profiler.scope(self, "update_origin", [])

	var node = get_node_or_null(target)
	if not node:
		return 

	var node_size = InterfaceSize.get_size(node)

	var offset = node_size * 0.5 * origin
	global_transform.origin = node.global_transform.origin + node.global_transform.basis.xform(offset)

func cache_relative_transform()->void :
	var scope = Profiler.scope(self, "cache_relative_transform", [])

	_relative_transform = Transform.IDENTITY

	var node = get_node(target)
	_relative_transform = global_transform.inverse() * node.global_transform

func apply_relative_transform()->void :
	var scope = Profiler.scope(self, "apply_relative_transform", [])

	var node = get_node(target)
	node.global_transform = (global_transform * _relative_transform).orthonormalized()

func snap_origin(step:float)->void :
	var scope = Profiler.scope(self, "snap_origin", [step])

	var snapped_origin = (global_transform.origin / step).round() * step
	var delta = snapped_origin - global_transform.origin

	var cached_check_collision = check_collision
	var cached_continuous_collision = continuous_collision
	check_collision = false
	continuous_collision = false
	proxy_move(delta)
	check_collision = cached_check_collision
	continuous_collision = cached_continuous_collision

func snap_rotation(step:float)->void :
	var scope = Profiler.scope(self, "snap_rotation", [step])

	var snapped_rotation = (rotation_degrees / step).round() * step
	var delta = snapped_rotation - rotation_degrees
	cache_relative_transform()
	rotation_degrees = snapped_rotation
	apply_relative_transform()

func proxy_move(delta:Vector3):
	var scope = Profiler.scope(self, "proxy_move", [delta])

	if not get_node_or_null(target):
		return 

	var shapes: = get_shapes()

	if check_collision:
		var collision = check_collision(delta, Vector3.ZERO, 0, shapes)
		if continuous_collision:
			var norm = delta.normalized()
			var step_delta = delta
			var i = 0
			while true:
				if collision:
					step_delta *= 0.5
					if step_delta.length() < STEP_HYSTERESIS:
						return null
					collision = check_collision(step_delta, Vector3.ZERO, 0, shapes)
					i += 1
				else :
					delta = step_delta
					break
		else :
			if collision:
				return null

	cache_relative_transform()
	global_transform.origin += delta
	apply_relative_transform()

	emit_signal("moved", delta)

	return delta

func proxy_move_3(delta:Vector3):
	var scope = Profiler.scope(self, "proxy_move_3", [delta])

	if not get_node_or_null(target):
		return 

	var out = Vector3.ZERO

	if delta.x != 0.0:
		var result = proxy_move(Vector3.RIGHT * delta.x)
		if result:
			out.x = result.x

	if delta.y != 0.0:
		var result = proxy_move(Vector3.UP * delta.y)
		if result:
			out.y = result.y

	if delta.z != 0.0:
		var result = proxy_move(Vector3.BACK * delta.z)
		if result:
			out.z = result.z

	if out == Vector3.ZERO:
		return null

	return out

func proxy_rotate(axis:Vector3, angle:float):
	var scope = Profiler.scope(self, "proxy_rotate", [axis, angle])

	if not get_node_or_null(target):
		return null

	var shapes: = get_shapes()

	if check_collision:
		var collision = check_collision(Vector3.ZERO, axis, angle, shapes)
		if collision:
			return null

	cache_relative_transform()
	transform.basis = (Basis(axis, angle) * transform.basis).orthonormalized()
	apply_relative_transform()

	emit_signal("rotated", angle)

	return angle

func proxy_rotate_euler(rotation_degrees:Vector3)->void :
	var scope = Profiler.scope(self, "proxy_rotate_euler", [rotation_degrees])

	if rotation_degrees.y != 0:
		proxy_rotate(Vector3.UP, deg2rad(rotation_degrees.y))

	if rotation_degrees.x != 0:
		proxy_rotate(Vector3.RIGHT, deg2rad(rotation_degrees.x))

	if rotation_degrees.z != 0:
		proxy_rotate(Vector3.FORWARD, deg2rad(rotation_degrees.z))

func get_shapes()->Dictionary:
	var scope = Profiler.scope(self, "get_shapes", [])

	var node = get_node(target)
	if not node:
		return {}

	var node_shapes: = InterfaceShapes.get_shapes(node)
	return node_shapes.get_shapes()

func check_collision(origin_delta:Vector3, rot_delta_axis:Vector3, rot_delta_angle:float, shapes:Dictionary)->bool:
	var scope = Profiler.scope(self, "check_collision", [origin_delta, rot_delta_axis, rot_delta_angle, shapes])

	var node = get_node(target)
	if not InterfaceRigidBody.is_implementor(node):
		return false
	var rigid_body = InterfaceRigidBody.get_rigid_body(node)

	var world = get_world()
	assert (world != null, "Can't check_collision without a valid world")

	var dss = world.get_direct_space_state()
	assert (dss != null, "Can't check_collision without a valid PhysicsDirectSpaceState")

	var intersection: = false
	for trx in shapes:
		var trx_shapes = shapes[trx]
		for shape in trx_shapes:
			var query = PhysicsShapeQueryParameters.new()
			query.transform = trx
			query.transform.origin += origin_delta
			if rot_delta_axis != Vector3.ZERO and rot_delta_angle != 0.0:
				query.transform.origin -= global_transform.origin
				query.transform = query.transform.rotated(rot_delta_axis, rot_delta_angle)
				query.transform.origin += global_transform.origin
			query.margin = - 0.1
			query.set_shape(shape)

			var exclude: = []
			exclude.append(rigid_body)
			query.exclude = exclude

			query.collision_mask = collision_mask

			var isects = dss.collide_shape(query)

			if isects.size() > 0:
				return true

	return false

