class_name CollisionObjectInputHandler
extends Node

export (NodePath) var composite_object_path
export (NodePath) var mouse_plane_path
export (NodePath) var movement_proxy_path
export (NodePath) var resize_proxy_path
export (NodePath) var widgets_path
export (NodePath) var coordinate_space_path
export (NodePath) var tool_mode_path


func get_composite_object()->CompositeObject:
	var scope = Profiler.scope(self, "get_composite_object", [])

	return get_node(composite_object_path) as CompositeObject

func get_mouse_plane()->MousePlane:
	var scope = Profiler.scope(self, "get_mouse_plane", [])

	return get_node(mouse_plane_path) as MousePlane

func get_movement_proxy()->MovementProxy:
	var scope = Profiler.scope(self, "get_movement_proxy", [])

	return get_node(movement_proxy_path) as MovementProxy

func get_resize_proxy()->ResizeProxy:
	var scope = Profiler.scope(self, "get_resize_proxy", [])

	return get_node(resize_proxy_path) as ResizeProxy

func get_widgets()->Spatial:
	var scope = Profiler.scope(self, "get_widgets", [])

	return get_node(widgets_path) as Spatial

func get_coordinate_space()->CoordinateSpace:
	var scope = Profiler.scope(self, "get_coordinate_space", [])

	return get_node(coordinate_space_path) as CoordinateSpace

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	var composite_object = get_composite_object()

	if event is InputEventMouseMotion:
		if not Input.is_mouse_button_pressed(BUTTON_LEFT) and not Input.is_mouse_button_pressed(BUTTON_RIGHT):
			var resize_proxy = get_resize_proxy()
			if InterfaceResizeProxyControl.is_implementor(node):
				var rpc = InterfaceResizeProxyControl.get_resize_proxy_control(node)
				resize_proxy.origin = rpc.origin
			else :
				resize_proxy.origin = Vector3.ZERO

			var mouse_plane = get_mouse_plane()
			mouse_plane.global_transform.origin = composite_object.global_transform.origin

			var camera_basis = get_viewport().get_camera().global_transform.basis

			if InterfaceMousePlaneControl.is_implementor(node):
				var mpc = InterfaceMousePlaneControl.get_mouse_plane_control(node)

				var use_local_space = get_coordinate_space().coordinate_space == CoordinateSpace.CoordinateSpace.Local or get_tool_mode().tool_mode == ToolMode.ToolMode.ResizeFace

				var basis: = Basis.IDENTITY
				match mpc.mode:
					MousePlaneControl.Mode.CustomBasis:
						basis = mpc.custom_basis
						if use_local_space:
							basis = (composite_object.global_transform.basis * basis).orthonormalized()
					MousePlaneControl.Mode.CameraAligned:
						basis = camera_basis
					MousePlaneControl.Mode.BillboardAxis:
						var axis = mpc.billboard_axis
						if use_local_space:
							axis = composite_object.global_transform.basis.xform(axis).normalized()
						var delta = (camera.global_transform.origin - composite_object.global_transform.origin)
						delta -= axis * axis.dot(delta)
						delta = delta.normalized()
						basis = Basis(delta.cross(axis).normalized(), axis, delta)

				mouse_plane.global_transform.basis = basis
				mouse_plane.axes = mpc.axes
			else :
				mouse_plane.global_transform.basis = camera_basis
				mouse_plane.axes = MousePlane.Axes.UV
