class_name SnapToFaceManager
extends Node




var snap_translation_interval = 1.0
func set_snap_translation_interval(new_snap_translation_interval)->void :
	var scope = Profiler.scope(self, "set_snap_translation_interval", [new_snap_translation_interval])

	if snap_translation_interval != new_snap_translation_interval:
		snap_translation_interval = new_snap_translation_interval

func snap_to_face():
	var scope = Profiler.scope(self, "snap_to_face", [])

	var selected_nodes = WorkshopDirectory.selected_nodes().selected_nodes
	if selected_nodes.size() != 1:
		return 

	var selected_node = selected_nodes[0]

	var hovered_node = WorkshopDirectory.hovered_node().hovered_node
	if not hovered_node:
		return 

	if hovered_node == selected_node:
		return 

	if selected_node.locked:
		return 

	var click_position = WorkshopDirectory.hovered_node().click_position
	var click_normal = WorkshopDirectory.hovered_node().click_normal

	var selected_move_origin = get_move_origin(selected_node, click_normal)

	var delta = click_position - selected_move_origin
	var trx = selected_node.transform
	trx.origin += delta
	trx.origin = trx.origin.snapped(Vector3.ONE * snap_translation_interval)

	AssignProperty.new(selected_node, "transform", trx).execute()

func get_move_origin(node:Spatial, click_normal:Vector3)->Vector3:
	var scope = Profiler.scope(self, "get_move_origin", [node, click_normal])

	if node is BrickHillObject:
		var bounds = node.get_bounds()
		bounds = Transform(node.global_transform.basis.orthonormalized(), Vector3.ZERO).xform(bounds)
		var extents = bounds.size * 0.5

		var dx = (extents.x * Vector3.RIGHT).dot(click_normal) * Vector3.RIGHT
		var dy = (extents.y * Vector3.UP).dot(click_normal) * Vector3.UP
		var dz = (extents.z * Vector3.BACK).dot(click_normal) * Vector3.BACK

		return node.global_transform.origin - (dx + dy + dz)
	return Vector3.ZERO
