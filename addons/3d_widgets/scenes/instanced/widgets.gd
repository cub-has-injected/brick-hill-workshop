class_name Widgets
extends Spatial
tool 

enum Widget{
	None, 
	MoveAxis, 
	MovePlane, 
	RotatePlane, 
	ResizeAxis, 
	ResizePlane
}

export (NodePath) var target: = NodePath()
export (NodePath) var tool_mode_path: = NodePath()
export (NodePath) var coordinate_space_path: = NodePath()
export (Widget) var widget: = Widget.MoveAxis setget set_widget

export (Vector3) var origin_offset: = Vector3.ZERO
export (Basis) var basis_offset: = Basis.IDENTITY

func set_widget(new_widget:int)->void :
	if widget != new_widget:
		widget = new_widget

func get_target()->Node:
	return get_node_or_null(target)

func get_tool_mode()->ToolMode:
	return get_node(tool_mode_path) as ToolMode

func get_coordinate_space()->CoordinateSpace:
	return get_node(coordinate_space_path) as CoordinateSpace

func _process(delta:float)->void :
	var node = get_target()
	if not node:
		return 

	var tool_mode = get_tool_mode().tool_mode

	$Offset.transform = Transform(basis_offset, origin_offset)

	$Offset / MoveAxisWidget.visible = tool_mode == ToolMode.ToolMode.MoveAxis
	$Offset / MovePlaneWidget.visible = tool_mode == ToolMode.ToolMode.MovePlane
	$Offset / RotatePlaneWidget.visible = tool_mode == ToolMode.ToolMode.RotatePlane
	$Offset / ResizeFaceWidget.visible = tool_mode == ToolMode.ToolMode.ResizeFace
	$Offset / ResizeEdgeWidget.visible = tool_mode == ToolMode.ToolMode.ResizeEdge
	$Offset / ResizeCornerWidget.visible = tool_mode == ToolMode.ToolMode.ResizeCorner

	var size = InterfaceSize.get_size(node)

	var coordinate_space = get_coordinate_space()
	if (coordinate_space.coordinate_space == CoordinateSpace.CoordinateSpace.Global
	 and tool_mode != ToolMode.ToolMode.ResizeFace
	 and tool_mode != ToolMode.ToolMode.ResizeEdge
	 and tool_mode != ToolMode.ToolMode.ResizeCorner
	):
		var world_aabb = Transform(node.global_transform.basis, Vector3.ZERO).xform(AABB( - size * 0.5, size))
		size = world_aabb.size

	for child in $Offset.get_children():
		if child.has_method("set_size"):
			child.set_size(size)

