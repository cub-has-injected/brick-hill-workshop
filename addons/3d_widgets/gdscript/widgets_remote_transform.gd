class_name WidgetsRemoteTransform
extends Node

enum PositionMode{
	None, 
	LocalCenter, 
	GroupOrigin, 
	TransformOrigin
}


export (NodePath) var source: = NodePath()
export (NodePath) var target: = NodePath()

export (PositionMode) var position_mode: = PositionMode.LocalCenter
export (bool) var update_rotation: = true
export (bool) var update_scale: = true

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var _source: = get_node_or_null(source)
	var _target: = get_node_or_null(target)

	if not is_instance_valid(_source) or not is_instance_valid(_target):
		return 

	match position_mode:
		PositionMode.LocalCenter:
			if InterfaceLocalCenter.is_implementor(_source):
				_target.transform.origin = InterfaceLocalCenter.get_local_center(_source)
		PositionMode.GroupOrigin:
			if InterfaceLocalCenter.is_implementor(_source) and InterfaceGroupOrigin.is_implementor(_source):
				_target.global_transform.origin = _source.global_transform.origin - InterfaceGroupOrigin.get_group_origin(_source)
		PositionMode.TransformOrigin:
			_target.transform.origin = _source.global_transform.origin

	if update_rotation:
		_target.transform.basis = _source.transform.basis.orthonormalized().scaled(_target.transform.basis.get_scale())

	if update_scale:
		_target.transform.basis = _target.transform.basis.orthonormalized().scaled(_source.transform.basis.get_scale())

func on_coordinate_space_changed(new_coordinate_space:int)->void :
	var scope = Profiler.scope(self, "on_coordinate_space_changed", [new_coordinate_space])

	if not is_inside_tree():
		return 

	match new_coordinate_space:
		CoordinateSpace.CoordinateSpace.Global:
			update_rotation = false
			var _target = get_node_or_null(target)
			get_node_or_null(target).global_transform.basis = Basis.IDENTITY
		CoordinateSpace.CoordinateSpace.Local:
			update_rotation = true
