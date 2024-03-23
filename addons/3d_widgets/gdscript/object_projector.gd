class_name ObjectProjector
extends Spatial

signal input_event(camera, event, click_position, click_normal, shape_idx)

export (float) var depth = 1.0
export (NodePath) var target: = NodePath()
export (bool) var apply_depth: = true

var _projected_mesh:Spatial = null

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	_projected_mesh = get_node(target)

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if is_visible_in_tree():
		project()

func project()->void :
	var scope = Profiler.scope(self, "project", [])
	var camera = get_viewport().get_camera()

	var unprojected_pos = camera.unproject_position(global_transform.origin)
	var unprojected_depth = camera.global_transform.basis.z.dot(camera.global_transform.origin - global_transform.origin)

	var reprojected_pos = camera.project_position(unprojected_pos, depth * sign(unprojected_depth))
	_projected_mesh.global_transform.origin = reprojected_pos

	if apply_depth:
		var d = 0.0
		if unprojected_depth != 0:
			d = abs(depth / unprojected_depth)
		_projected_mesh.global_transform.basis = _projected_mesh.global_transform.basis.orthonormalized().scaled(Vector3(d, d, d))

func _on_input_event(camera:Node, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "_on_input_event", [camera, event, click_position, click_normal, shape_idx])

	var local_click = $ProjectedMesh.global_transform.origin - click_position
	var unprojected_pos = camera.unproject_position(click_position)
	var unprojected_depth = camera.global_transform.basis.z.dot(camera.global_transform.origin - global_transform.origin)

	var d = unprojected_depth / depth

	emit_signal("input_event", camera, event, global_transform.origin - local_click * d, click_normal, shape_idx)
