class_name RigidBodyVCR
extends Node

export (Array, NodePath) var dynamic_rigid_body_paths: = []
export (int) var buffer_size: = 60

var _rewind_buffer: = []

func _unhandled_key_input(event:InputEventKey)->void :
	if event.pressed and not event.is_echo():
		var tree = get_tree()
		match event.scancode:
			KEY_PAUSE:
				tree.paused = not get_tree().paused
				_rewind_buffer.clear()
			KEY_PAGEUP:
				if tree.paused:
					yield (tree, "physics_frame")
					tree.paused = false

				advance()

				yield (tree, "physics_frame")
				tree.paused = true
			KEY_PAGEDOWN:
				if _rewind_buffer.size() == 0:
					return 

				if tree.paused:
					yield (tree, "physics_frame")
					tree.paused = false

				rewind()

				yield (tree, "physics_frame")
				tree.paused = true
			KEY_END:
				if _rewind_buffer.size() == 0:
					return 

				if tree.paused:
					yield (tree, "physics_frame")
					tree.paused = false

				rewind(true)

				yield (tree, "physics_frame")
				tree.paused = true


func advance()->void :
	var state: = {}
	for path in dynamic_rigid_body_paths:
		var node = get_node_or_null(path)
		if node is RigidBody:
			state[node] = {
				"global_transform":node.global_transform, 
				"linear_velocity":node.linear_velocity, 
				"angular_velocity":node.angular_velocity
			}

	if state.empty():
		return 

	_rewind_buffer.append(state)
	if _rewind_buffer.size() > buffer_size:
		_rewind_buffer.remove(0)

func rewind(full:bool = false)->void :
	var prev_state = null
	if full:
		prev_state = _rewind_buffer.pop_front()
		_rewind_buffer.clear()
	else :
		prev_state = _rewind_buffer.pop_back()

	if prev_state:
		for node in prev_state:
			var state = prev_state[node]
			node.global_transform = state.global_transform
			node.linear_velocity = state.linear_velocity
			node.angular_velocity = state.angular_velocity
