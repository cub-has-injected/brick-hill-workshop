class_name PhysicsLerpRemoteTransform
extends Spatial
tool 

export (NodePath) var target: = NodePath()

var _transform_window: = [null, null]

func _physics_process(delta:float)->void :
	var scope = Profiler.scope(self, "_physics_process", [delta])

	var node = get_node_or_null(target)
	if not node:
		return 

	var trx = node.global_transform

	if _transform_window[0] == null:
		_transform_window[0] = trx
	elif _transform_window[1] == null:
		_transform_window[1] = trx
	else :
		_transform_window[0] = _transform_window[1]
		_transform_window[1] = trx

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var from = _transform_window[0]
	var to = _transform_window[1]
	if from != null and to != null:
		var interp = from.interpolate_with(to, Engine.get_physics_interpolation_fraction())
		global_transform = interp
