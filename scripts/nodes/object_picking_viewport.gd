class_name ObjectPickingViewport
extends Viewport

signal hovered_node_changed()
signal dragged_node_changed()

signal node_pressed(node, camera, event, click_position, click_normal, shape_idx)
signal node_dragged(node, camera, event, click_position, click_normal, shape_idx)
signal node_hovered(node, camera, event, click_position, click_normal, shape_idx)
signal node_released(node, camera, event, click_position, click_normal, shape_idx)

var _hovered_node:Node setget _set_hovered_node, get_hovered_node
var _dragged_node:Node setget _set_dragged_node, get_dragged_node


func _set_hovered_node(new_hovered_node:Node)->void :
	var scope = Profiler.scope(self, "_set_hovered_node", [new_hovered_node])

	if _hovered_node != new_hovered_node:
		_hovered_node = new_hovered_node
		emit_signal("hovered_node_changed")

func _set_dragged_node(new_dragged_node:Node)->void :
	var scope = Profiler.scope(self, "_set_dragged_node", [new_dragged_node])

	if _dragged_node != new_dragged_node:
		_dragged_node = new_dragged_node
		emit_signal("dragged_node_changed")


func get_hovered_node()->Node:
	var scope = Profiler.scope(self, "get_hovered_node", [])

	return _hovered_node

func get_dragged_node()->Node:
	var scope = Profiler.scope(self, "get_dragged_node", [])

	return _dragged_node


func node_hovered(node:Node)->void :
	var scope = Profiler.scope(self, "node_hovered", [node])

	_set_hovered_node(node)

func node_unhovered(node:Node)->void :
	var scope = Profiler.scope(self, "node_unhovered", [node])

	_set_hovered_node(null)

func input_event(node:Node, camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "input_event", [node, camera, event, click_position, click_normal, shape_idx])

	if event is InputEventMouseButton:
		input_event_mouse_button(node, camera, event, click_position, click_normal, shape_idx)
	elif event is InputEventMouseMotion:
		input_event_mouse_motion(node, camera, event, click_position, click_normal, shape_idx)

func input_event_mouse_button(node:Node, camera:Object, event:InputEventMouseButton, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "input_event_mouse_button", [node, camera, event, click_position, click_normal, shape_idx])

	if event.button_index == BUTTON_LEFT:
		if event.pressed:
			emit_signal("node_pressed", node, camera, event, click_position, click_normal, shape_idx)
			_set_dragged_node(node)
		else :
			emit_signal("node_released", node, camera, event, click_position, click_normal, shape_idx)
			_set_dragged_node(null)

func input_event_mouse_motion(node:Node, camera:Object, event:InputEventMouseMotion, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	var scope = Profiler.scope(self, "input_event_mouse_motion", [node, camera, event, click_position, click_normal, shape_idx])

	if _dragged_node:
		emit_signal("node_dragged", node, camera, event, click_position, click_normal, shape_idx)
	elif _hovered_node:
		emit_signal("node_hovered", node, camera, event, click_position, click_normal, shape_idx)


func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	_set_hovered_node(null)

	if _dragged_node:
		emit_signal("node_released", _dragged_node, get_viewport().get_camera(), InputEventMouseButton.new(), Vector3.ZERO, Vector3.ZERO, - 1)
		_set_dragged_node(null)
