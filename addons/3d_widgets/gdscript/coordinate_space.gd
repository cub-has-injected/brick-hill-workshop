class_name CoordinateSpace
extends Node

signal changed(new_coordinate_space)

enum CoordinateSpace{
	Global, 
	Local
}

export (NodePath) var tool_mode_path: = NodePath()
export (CoordinateSpace) var coordinate_space: = CoordinateSpace.Global setget set_coordinate_space

func set_coordinate_space(new_coordinate_space:int)->void :
	var scope = Profiler.scope(self, "set_coordinate_space", [new_coordinate_space])

	if coordinate_space != new_coordinate_space:
		coordinate_space = new_coordinate_space
		update_coordinate_space()

func set_space_global()->void :
	var scope = Profiler.scope(self, "set_space_global", [])

	set_coordinate_space(CoordinateSpace.Global)

func set_space_local()->void :
	var scope = Profiler.scope(self, "set_space_local", [])

	set_coordinate_space(CoordinateSpace.Local)

func get_tool_mode()->ToolMode:
	var scope = Profiler.scope(self, "get_tool_mode", [])

	return get_node(tool_mode_path) as ToolMode

func update_coordinate_space()->void :
	var scope = Profiler.scope(self, "update_coordinate_space", [])

	var cs = coordinate_space

	var tool_mode = get_tool_mode().tool_mode
	if (tool_mode == ToolMode.ToolMode.ResizeFace
	 or tool_mode == ToolMode.ToolMode.ResizeEdge
	 or tool_mode == ToolMode.ToolMode.ResizeCorner
	):
		cs = CoordinateSpace.Local

	emit_signal("changed", cs)

func on_tool_mode_changed(new_mode:int)->void :
	var scope = Profiler.scope(self, "on_tool_mode_changed", [new_mode])

	update_coordinate_space()
