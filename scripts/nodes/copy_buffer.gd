class_name WorkshopCopyBuffer
extends Node

var copy_buffer: = []
var copy_positions: = []

func copy(nodes:Array)->void :
	var scope = Profiler.scope(self, "copy", [nodes])

	clear()

	for node in nodes:
		copy_positions.append(node.global_transform.origin)
		var copy_node = node.duplicate(DUPLICATE_GROUPS | DUPLICATE_SIGNALS | DUPLICATE_SCRIPTS)
		copy_buffer.append(copy_node)

func paste(parent:Node)->void :
	var scope = Profiler.scope(self, "paste", [parent])

	BeginCompositeAction.new().execute()

	var nodes: = []
	for copy_node in copy_buffer:
		var node = copy_node.duplicate()
		node.name = copy_node.name
		CreateNodeAction.new(node, parent).execute()
		nodes.append(node)

	EndCompositeAction.new().execute()

	position_nodes(nodes)

func position_nodes(nodes:Array)->void :
	var scope = Profiler.scope(self, "position_nodes", [nodes])

	for i in range(0, nodes.size()):
		var node = nodes[i]
		node.global_transform.origin = copy_positions[i]

func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	for node in copy_buffer:
		node.queue_free()
	copy_buffer.clear()
	copy_positions.clear()
