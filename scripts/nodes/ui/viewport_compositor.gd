class_name ViewportCompositor
extends ViewportSizer
tool 

const PRINT_DEBUG: = true

signal hovered_node_changed()
signal dragged_node_changed()

signal node_hovered(node, camera, event, click_position, click_normal, shape_idx, viewport)
signal node_pressed(node, camera, event, click_position, click_normal, shape_idx, viewport)
signal node_dragged(node, camera, event, click_position, click_normal, shape_idx, viewport)
signal node_released(node, camera, event, click_position, click_normal, shape_idx, viewport)

signal viewport_pressed(event)

signal click_position_changed()
signal click_normal_changed()

var _active_viewport:Viewport setget _set_active_viewport
var _dragged_node:Node setget _set_dragged_node, get_dragged_node

var _click_position:Vector3 setget _set_click_position, get_click_position
var _click_normal:Vector3 setget _set_click_normal, get_click_normal


func _set_active_viewport(new_active_viewport:Viewport)->void :
	var scope = Profiler.scope(self, "_set_active_viewport", [new_active_viewport])

	if _active_viewport != new_active_viewport:
		_active_viewport = new_active_viewport
		update_dragged_node()

func _set_dragged_node(new_dragged_node:Node)->void :
	var scope = Profiler.scope(self, "_set_dragged_node", [new_dragged_node])

	if _dragged_node != new_dragged_node:
		_dragged_node = new_dragged_node
		emit_signal("dragged_node_changed")

func _set_click_position(new_click_position:Vector3)->void :
	var scope = Profiler.scope(self, "_set_click_position", [new_click_position])

	if _click_position != new_click_position:
		_click_position = new_click_position
		emit_signal("click_position_changed")

func _set_click_normal(new_click_normal:Vector3)->void :
	var scope = Profiler.scope(self, "_set_click_normal", [new_click_normal])

	if _click_normal != new_click_normal:
		_click_normal = new_click_normal
		emit_signal("click_normal_changed")


func get_dragged_node()->Node:
	var scope = Profiler.scope(self, "get_dragged_node", [])

	return _dragged_node

func get_click_position()->Vector3:
	var scope = Profiler.scope(self, "get_click_position", [])

	return _click_position

func get_click_normal()->Vector3:
	var scope = Profiler.scope(self, "get_click_normal", [])

	return _click_normal


func update_active_viewport()->void :
	var scope = Profiler.scope(self, "update_active_viewport", [])

	var children = get_children()

	if _dragged_node and _dragged_node.input_capture_on_drag:
		return 

	_set_active_viewport(null)

func update_dragged_node()->void :
	var scope = Profiler.scope(self, "update_dragged_node", [])

	var dragged_node = null
	if _active_viewport:
		dragged_node = _active_viewport.get_dragged_node()
	_set_dragged_node(dragged_node)


func viewport_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "viewport_input", [event])

	for child in get_children():
		assert (child is Viewport)
		child.unhandled_input(event)

	
	if event is InputEventMouseMotion:
		if _dragged_node:
			if not Input.is_mouse_button_pressed(BUTTON_LEFT):
				_dragged_node.get_viewport().clear()

func hovered_node_changed(viewport:Viewport)->void :
	var scope = Profiler.scope(self, "hovered_node_changed", [viewport])

	update_active_viewport()

func dragged_node_changed(viewport:Viewport)->void :
	var scope = Profiler.scope(self, "dragged_node_changed", [viewport])

	update_dragged_node()

func node_hovered(node:Node, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int, viewport:Viewport)->void :
	var scope = Profiler.scope(self, "node_hovered", [node, camera, event, click_position, click_normal, shape_idx, viewport])

	if viewport != _active_viewport:
		return 

	if PRINT_DEBUG:
		print_debug("%s Node hovered: %s" % [get_tree().get_frame(), node.get_name()])

	_set_click_position(click_position)
	_set_click_normal(click_normal)

	emit_signal("node_hovered", node, camera, event, click_position, click_normal, shape_idx, viewport)

func node_pressed(node:Node, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int, viewport:Viewport)->void :
	var scope = Profiler.scope(self, "node_pressed", [node, camera, event, click_position, click_normal, shape_idx, viewport])

	if viewport != _active_viewport:
		return 

	if PRINT_DEBUG:
		print_debug("%s Node pressed: %s" % [get_tree().get_frame(), node.get_name()])

	_set_click_position(click_position)
	_set_click_normal(click_normal)

	emit_signal("node_pressed", node, camera, event, click_position, click_normal, shape_idx, viewport)

func node_dragged(node:Node, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int, viewport:Viewport)->void :
	var scope = Profiler.scope(self, "node_dragged", [node, camera, event, click_position, click_normal, shape_idx, viewport])

	if viewport != _active_viewport:
		return 

	if PRINT_DEBUG:
		print_debug("%s Node dragged: %s" % [get_tree().get_frame(), node.get_name()])

	_set_click_position(click_position)
	_set_click_normal(click_normal)

	emit_signal("node_dragged", node, camera, event, click_position, click_normal, shape_idx, viewport)

func node_released(node:Node, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int, viewport:Viewport)->void :
	var scope = Profiler.scope(self, "node_released", [node, camera, event, click_position, click_normal, shape_idx, viewport])

	if viewport != _active_viewport:
		return 

	if PRINT_DEBUG:
		print_debug("%s Node released: %s" % [get_tree().get_frame(), node.get_name()])

	_set_click_position(click_position)
	_set_click_normal(click_normal)

	emit_signal("node_released", node, camera, event, click_position, click_normal, shape_idx, viewport)
	call_deferred("update_active_viewport")
