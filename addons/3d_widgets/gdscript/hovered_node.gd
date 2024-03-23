class_name HoveredNode
extends Node



signal hovered_node_changed()
signal hover_normal_changed()

var hovered_node:Node = null setget set_hovered_node
var hover_normal:Vector3 = Vector3.ZERO setget set_hover_normal

func set_hovered_node(new_hovered_node:Node)->void :
	var scope = Profiler.scope(self, "set_hovered_node", [new_hovered_node])

	if hovered_node != new_hovered_node:
		if is_instance_valid(hovered_node) and hovered_node.has_method("unhovered"):
			hovered_node.unhovered()

		hovered_node = new_hovered_node

		if is_instance_valid(hovered_node) and hovered_node.has_method("hovered"):
			hovered_node.hovered()

		emit_signal("hovered_node_changed")

func set_hover_normal(new_hover_normal:Vector3)->void :
	var scope = Profiler.scope(self, "set_hover_normal", [new_hover_normal])

	if hover_normal != new_hover_normal:
		hover_normal = new_hover_normal
		emit_signal("hover_normal_changed")
