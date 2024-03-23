class_name SelectedNodes
extends Node



signal selected_nodes_changed()
signal node_selected(node)
signal node_deselected(node)

var selected_nodes: = [] setget set_selected_nodes

func add_selected_node(node:Node)->void :
	var scope = Profiler.scope(self, "add_selected_node", [node])

	if not node:
		return 

	if not node in selected_nodes:
		selected_nodes.append(node)

		if node.has_method("selected"):
			node.call("selected")

		emit_signal("node_selected", node)
		emit_signal("selected_nodes_changed")

func remove_selected_node(node:Node)->void :
	var scope = Profiler.scope(self, "remove_selected_node", [node])

	if not node:
		return 

	if node in selected_nodes:
		selected_nodes.erase(node)

		if node.has_method("unselected"):
			node.call("unselected")

		emit_signal("node_deselected", node)
		emit_signal("selected_nodes_changed")

func set_selected_nodes(new_selected_nodes:Array)->void :
	var scope = Profiler.scope(self, "set_selected_nodes", [new_selected_nodes])

	if selected_nodes != new_selected_nodes:
		var to_remove: = []
		for node in selected_nodes:
			if not node in new_selected_nodes:
				to_remove.append(node)

		for node in to_remove:
			remove_selected_node(node)

		var to_add: = []
		for node in new_selected_nodes:
			if not node in selected_nodes:
				to_add.append(node)

		for node in to_add:
			add_selected_node(node)

func clear_selected_nodes()->void :
	var scope = Profiler.scope(self, "clear_selected_nodes", [])

	if selected_nodes.size() == 0:
		return 

	for node in selected_nodes:
		if node.has_method("unselected"):
			node.call("unselected")

		emit_signal("node_deselected", node)

	selected_nodes.clear()
	emit_signal("selected_nodes_changed")
