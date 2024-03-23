"\nMouse-interactible plane that projects input events into 3D space\n"

class_name MousePlane
extends Spatial
tool 

const DEBUG: = false

signal plane_entered()
signal plane_exited(plane, event)
signal plane_event()

enum Axes{
	UV = 0, 
	U = 1, 
	V = 2, 
}

export (int, "UV,U,V") var axes: = Axes.UV

var _point_debug_geo = null
var _prev_intersection = null

class EventPlane:
	pass

class EventPlaneButton extends EventPlane:
	var origin:Vector3
	var pressed:bool
	var button_index:int
	var button_mask:int

	func _init(in_origin:Vector3, in_pressed:bool, in_button_index:int, in_button_mask:int)->void :
		var scope = Profiler.scope(self, "_init", [in_origin, in_pressed, in_button_index, in_button_mask])

		origin = in_origin
		pressed = in_pressed
		button_index = in_button_index
		button_mask = in_button_mask

class EventPlaneMotion extends EventPlane:
	var origin:Vector3
	var relative:Vector3

	func _init(in_origin:Vector3, in_relative:Vector3)->void :
		var scope = Profiler.scope(self, "_init", [in_origin, in_relative])

		origin = in_origin
		relative = in_relative

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	add_to_group("collision_object_input_events")

	for child in get_children():
		if child.has_meta("mouse_plane_child"):
			remove_child(child)
			child.queue_free()

	if DEBUG:
		_point_debug_geo = PointDebugGeo.new()
		_point_debug_geo.set_meta("mouse_plane_child", true)
		add_child(_point_debug_geo)


func on_collision_object_input_enter_tree(node:CollisionObjectInput)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_enter_tree", [node])

	node.connect("collision_object_input_event", self, "on_collision_object_input_event")

func on_collision_object_input_event(node:CollisionObject, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "on_collision_object_input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if event is InputEventMouse:
		var ray_origin = camera.project_ray_origin(event.position)
		var ray_normal = camera.project_ray_normal(event.position)

		var plane = Plane(global_transform.basis.z, global_transform.origin.dot(global_transform.basis.z))

		var intersection = plane.intersects_ray(ray_origin, ray_normal)

		if intersection:
			if axes != Axes.UV:
				intersection = global_transform.xform_inv(intersection)
				match axes:
					Axes.U:
						intersection.y = 0
					Axes.V:
						intersection.x = 0
				intersection = global_transform.xform(intersection)

		if intersection != null and _prev_intersection == null:
			emit_signal("plane_entered")

		if intersection == null and _prev_intersection != null:
			emit_signal("plane_exited")

		if DEBUG:
			if intersection and _prev_intersection:
				_point_debug_geo.global_transform.origin = intersection
				_point_debug_geo.visible = true
			else :
				_point_debug_geo.transform = Transform.IDENTITY
				_point_debug_geo.visible = false

		if intersection:
			if event is InputEventMouseMotion:
				var delta: = Vector3.ZERO

				if _prev_intersection:
					delta = intersection - _prev_intersection

					emit_signal("plane_event", self, EventPlaneMotion.new(intersection, delta))
			elif event is InputEventMouseButton:
				emit_signal("plane_event", self, EventPlaneButton.new(intersection, event.pressed, event.button_index, event.button_mask))

		_prev_intersection = intersection
