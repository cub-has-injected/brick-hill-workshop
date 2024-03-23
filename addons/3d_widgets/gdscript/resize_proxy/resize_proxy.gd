class_name ResizeProxy
extends Node
tool 

signal resized()

export (NodePath) var movement_proxy_path: = NodePath()
export (Vector3) var origin: = Vector3.ZERO
export (float) var min_size: = 1.0 setget set_min_size

func set_min_size(new_min_size:float)->void :
	var scope = Profiler.scope(self, "set_min_size", [new_min_size])

	if min_size != new_min_size:
		min_size = new_min_size

func get_movement_proxy()->MovementProxy:
	var scope = Profiler.scope(self, "get_movement_proxy", [])

	return get_node(movement_proxy_path) as MovementProxy

func nudge_corner(delta:Vector3)->void :
	var scope = Profiler.scope(self, "nudge_corner", [delta])

	var movement_proxy = get_movement_proxy()
	var movement_target = movement_proxy.get_node_or_null(movement_proxy.target)

	var target_node:Spatial
	if movement_target is CompositeObject:
		var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes

		if selected_nodes.size() != 1:
			return 

		target_node = selected_nodes[0]
	else :
		target_node = movement_target

	var basis = target_node.global_transform.basis
	delta = basis.xform_inv(delta)

	var size = InterfaceSize.get_size(target_node)

	for c in range(0, 3):
		var axis = origin[c]
		var amount = delta[c]
		var axis_size = size[c]
		var target_size = axis_size + axis * amount

		var local_axis = Vector3.ZERO
		local_axis[c] = 1.0

		movement_proxy.continuous_collision = false
		if sign(axis) != sign(amount):
			if target_size < min_size:
				amount += (min_size - target_size) * sign(axis)

			var cached_check_collision = movement_proxy.check_collision
			movement_proxy.check_collision = false
			movement_proxy.proxy_move(basis[c] * abs(axis) * amount * 0.5)
			InterfaceSize.offset_aabb_size(target_node, local_axis * sign(axis) * amount)
			movement_proxy.update_origin()
			movement_proxy.check_collision = cached_check_collision
			emit_signal("resized")
		else :
			var result = movement_proxy.proxy_move(basis[c] * abs(axis) * amount * 0.5)
			if result != null:
				InterfaceSize.offset_aabb_size(target_node, local_axis * sign(axis) * amount)
				movement_proxy.update_origin()
				emit_signal("resized")
