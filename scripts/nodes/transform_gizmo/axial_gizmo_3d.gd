class_name AxialGizmo3D
extends Spatial
tool 

enum GizmoAxis{
	NONE, 
	X, 
	Y, 
	Z
}

export (Mesh) var mesh setget set_mesh
export (Shape) var shape setget set_shape
export (float) var mesh_offset: = 1.0 setget set_mesh_offset
export (float) var mesh_scale: = 1.0 setget set_mesh_scale
export (bool) var show_dot: = true setget set_show_dot

var _extents = Vector3.ONE * 4.0 setget set_extents

var _gizmo_axis:int = GizmoAxis.NONE
var _drag_plane = null

var _x_material:Material = preload("res://resources/material/gizmo/GizmoX.tres")
var _y_material:Material = preload("res://resources/material/gizmo/GizmoY.tres")
var _z_material:Material = preload("res://resources/material/gizmo/GizmoZ.tres")


func set_mesh(new_mesh:Mesh)->void :
	var scope = Profiler.scope(self, "set_mesh", [new_mesh])

	if mesh != new_mesh:
		mesh = new_mesh
		if is_inside_tree():
			update_mesh()

func set_shape(new_shape:Shape)->void :
	var scope = Profiler.scope(self, "set_shape", [new_shape])

	if shape != new_shape:
		shape = new_shape
		if is_inside_tree():
			update_shape()

func set_mesh_offset(new_mesh_offset:float)->void :
	var scope = Profiler.scope(self, "set_mesh_offset", [new_mesh_offset])

	if mesh_offset != new_mesh_offset:
		mesh_offset = new_mesh_offset
		if is_inside_tree():
			update_mesh_offset()

func set_mesh_scale(new_mesh_scale:float)->void :
	var scope = Profiler.scope(self, "set_mesh_scale", [new_mesh_scale])

	if mesh_scale != new_mesh_scale:
		mesh_scale = new_mesh_scale
		if is_inside_tree():
			update_mesh_scale()

func set_show_dot(new_show_dot:bool)->void :
	var scope = Profiler.scope(self, "set_show_dot", [new_show_dot])

	if show_dot != new_show_dot:
		show_dot = new_show_dot
		if is_inside_tree():
			update_show_dot()

func set_extents(new_extents:Vector3)->void :
	var scope = Profiler.scope(self, "set_extents", [new_extents])

	if _extents != new_extents:
		_extents = new_extents
		extents_changed()


func get_handle_x()->GizmoHandle:
	var scope = Profiler.scope(self, "get_handle_x", [])

	return $AreaX as GizmoHandle

func get_handle_y()->GizmoHandle:
	var scope = Profiler.scope(self, "get_handle_y", [])

	return $AreaY as GizmoHandle

func get_handle_z()->GizmoHandle:
	var scope = Profiler.scope(self, "get_handle_z", [])

	return $AreaZ as GizmoHandle


func update_mesh_offset():
	var scope = Profiler.scope(self, "update_mesh_offset", [])

	var offset_vec = Vector3(mesh_offset, mesh_offset, mesh_offset)
	var offset = (_extents * 0.5) + offset_vec
	get_handle_x().transform.origin = Vector3(offset.x, 0, 0)
	get_handle_y().transform.origin = Vector3(0, offset.y, 0)
	get_handle_z().transform.origin = Vector3(0, 0, offset.z)

func update_mesh_scale():
	var scope = Profiler.scope(self, "update_mesh_scale", [])

	get_handle_x().scale = Vector3(mesh_scale, mesh_scale, mesh_scale)
	get_handle_y().scale = Vector3(mesh_scale, mesh_scale, mesh_scale)
	get_handle_z().scale = Vector3(mesh_scale, mesh_scale, mesh_scale)

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	get_handle_x().mesh = mesh
	get_handle_y().mesh = mesh
	get_handle_z().mesh = mesh

func update_shape()->void :
	var scope = Profiler.scope(self, "update_shape", [])

	get_handle_x().shape = shape
	get_handle_y().shape = shape
	get_handle_z().shape = shape

func update_show_dot()->void :
	var scope = Profiler.scope(self, "update_show_dot", [])

	get_handle_x().show_dot = show_dot
	get_handle_y().show_dot = show_dot
	get_handle_z().show_dot = show_dot

func extents_changed()->void :
	var scope = Profiler.scope(self, "extents_changed", [])

	update_mesh_offset()


func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	get_handle_x().material = _x_material.duplicate()
	get_handle_y().material = _y_material.duplicate()
	get_handle_z().material = _z_material.duplicate()

	update_mesh()
	update_shape()
	update_mesh_offset()
	update_mesh_scale()
	update_show_dot()

func set_visible(new_visible:bool)->void :
	var scope = Profiler.scope(self, "set_visible", [new_visible])

	.set_visible(new_visible)
	get_handle_x().collision_layer = 1 if visible else 0
	get_handle_y().collision_layer = 1 if visible else 0
	get_handle_z().collision_layer = 1 if visible else 0
