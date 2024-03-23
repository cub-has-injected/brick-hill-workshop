extends Tree
tool 

signal node_selected(node)
signal node_deselected(node)

export (String) var node_name_filter = "" setget set_node_name_filter



func set_node_name_filter(new_node_name_filter:String)->void :
	var scope = Profiler.scope(self, "set_node_name_filter", [new_node_name_filter])

	if node_name_filter != new_node_name_filter:
		node_name_filter = new_node_name_filter
		update_tree()



func get_set_root()->Spatial:
	var scope = Profiler.scope(self, "get_set_root", [])

	var set_root: = WorkshopDirectory.set_root() as SetRoot
	if not set_root:
		return null

	return set_root


func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	connect("multi_selected", self, "multi_selected")
	set_hide_root(true)
	update_tree()

func _gui_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_gui_input", [event])

	
	
	if event is InputEventKey:
		if event.pressed:
			var focused_item = get_selected()
			var target_item = null
			if focused_item and focused_item.is_selected(0):
				if event.scancode == KEY_UP:
					var prev_item = focused_item.get_prev()
					if prev_item:
						var first_child = prev_item.get_children()
						if prev_item.collapsed or not first_child:
							target_item = prev_item
						else :
							var candidate = first_child
							while true:
								var next_child = candidate.get_next()
								if next_child:
									candidate = next_child
								else :
									break
							target_item = candidate
					else :
						var parent_item = focused_item.get_parent()
						if parent_item and not parent_item == get_root():
							target_item = parent_item
				elif event.scancode == KEY_DOWN:
					var first_child = focused_item.get_children()
					if focused_item.collapsed or not first_child:
						var next_item = focused_item.get_next()
						if next_item:
							target_item = next_item
						else :
							var parent_item = focused_item.get_parent()
							if parent_item and not parent_item == get_root():
								var next_parent_item = parent_item.get_next()
								if next_parent_item:
									target_item = next_parent_item
					else :
						target_item = first_child
				elif event.scancode == KEY_RIGHT:
					if not focused_item.collapsed:
						
						var first_child = focused_item.get_children()
						if first_child:
							target_item = first_child
						else :
							var next_item = focused_item.get_next()
							if next_item:
								target_item = next_item
							else :
								var parent_item = focused_item.get_parent()
								if parent_item and not parent_item == get_root():
									var next_parent_item = parent_item.get_next()
									if next_parent_item:
										target_item = next_parent_item

			if target_item:
				focused_item.deselect(0)
				var focused_node = focused_item.get_metadata(0)
				if focused_node:
					emit_signal("node_deselected", focused_node)

				target_item.select(0)
				var target_node = target_item.get_metadata(0)
				if target_node:
					emit_signal("node_selected", target_node)


func get_drag_data(position:Vector2):
	var scope = Profiler.scope(self, "get_drag_data", [position])

	var selected_items: = []

	var candidate = get_selected()
	while true:
		if not candidate:
			break
		selected_items.append(candidate)
		candidate = get_next_selected(candidate)

	set_drop_mode_flags(DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM)

	var preview = null
	if selected_items.size() > 0:
		preview = Label.new()
		preview.text = selected_items[0].get_text(0)
		set_drag_preview(preview)

	return selected_items


func can_drop_data(position:Vector2, data):
	var scope = Profiler.scope(self, "can_drop_data", [position, data])

	if not data is Array:
		return false

	for item in data:
		if not item is TreeItem:
			return false

	return true


func drop_data(position:Vector2, from_items:Array):
	var scope = Profiler.scope(self, "drop_data", [position, from_items])

	
	var to_item = get_item_at_position(position)

	
	if from_items.size() == 0:
		return 

	
	if from_items.size() == 0 or not to_item or (from_items.size() == 1 and from_items[0] == to_item):
		return 

	
	var shift = get_drop_section_at_position(position)

	
	match shift:
		1:
			if to_item == from_items[0].get_prev():
				return 
		- 1:
			if to_item == from_items[ - 1].get_next():
				return 

	
	var from_nodes: = []
	for item in from_items:
		from_nodes.append(item.get_metadata(0))

	var to_node = to_item.get_metadata(0)

	
	var to_index = to_node.get_index()

	
	var from_parent_items: = []
	for item in from_items:
		from_parent_items.append(item.get_parent())
	var to_parent_item = to_item.get_parent()

	
	for i in range(0, from_nodes.size()):
		var from_parent_item = from_parent_items[i]
		var from_node = from_nodes[i]
		if from_parent_item == to_parent_item:
			var from_index = from_node.get_index()
			if from_index < to_index:
				shift = min(shift, 0)
			elif from_index > to_index:
				shift = max(shift, 0)

	
	if to_node is BrickHillGroup and shift > 0:
		to_index = 0
		shift = 0

	
	var from_parent = from_nodes[0].get_parent()
	var to_parent = to_node if to_node is BrickHillGroup and shift >= 0 else to_node.get_parent()

	
	to_index += shift

	
	to_index = clamp(to_index, 0, to_parent.get_child_count())

	
	BeginCompositeAction.new().execute()

	for i in range(0, from_nodes.size()):
		var node = from_nodes[i]
		ReparentChildAction.new(node.get_parent(), from_parent, node, to_index + i).execute()

	EndCompositeAction.new().execute()


	
	update_tree()



func update_tree()->void :
	var scope = Profiler.scope(self, "update_tree", [])

	clear()
	var tree_root = create_item()

	var set_root = get_set_root()
	if not set_root:
		return 

	traverse(set_root, tree_root)
	populate_selected_nodes([])


func traverse(node:Node, parent_item:TreeItem = null)->void :
	var scope = Profiler.scope(self, "traverse", [node, parent_item])

	var item:TreeItem = null

	if node is SetRoot or node is BrickHillObject:
		var node_name = node.get_name()
		if node_name_filter == "" or node_name.to_lower().find(node_name_filter.to_lower()) != - 1:
			item = create_item(parent_item)
			item.set_text(0, node.get_name())
			item.set_metadata(0, node)
			node_shape_changed(node, item)

			BrickHillUtil.connect_checked(
				node, 
				"renamed", 
				self, 
				"item_renamed", 
				[node, item]
			)

			if node is BrickHillBrickObject:
				BrickHillUtil.connect_checked(
					node, 
					"shape_changed", 
					self, 
					"node_shape_changed", 
					[node, item]
				)

	if item:
		for child in node.get_children():
			traverse(child, item)


func item_renamed(node:Node, item:TreeItem)->void :
	var scope = Profiler.scope(self, "item_renamed", [node, item])

	item.set_text(0, node.get_name())


func node_shape_changed(node:BrickHillObject, item:TreeItem)->void :
	var scope = Profiler.scope(self, "node_shape_changed", [node, item])

	if not node or not item:
		return 

	item.set_icon(0, node.get_tree_icon(false))
	item.set_meta("tree_icon", node.get_tree_icon(false))
	item.set_meta("tree_icon_highlight", node.get_tree_icon(true))


func multi_selected(item:TreeItem, _column:int, selected:bool)->void :
	var scope = Profiler.scope(self, "multi_selected", [item, _column, selected])

	var node = item.get_metadata(0)
	if selected:
		emit_signal("node_selected", node)
	else :
		emit_signal("node_deselected", node)


var selected_nodes: = []

func selected_nodes_changed()->void :
	var scope = Profiler.scope(self, "selected_nodes_changed", [])

	populate_selected_nodes(WorkshopDirectory.selected_nodes().selected_nodes)

func node_selected(node:Node)->void :
	var scope = Profiler.scope(self, "node_selected", [node])

	selected_nodes.append(node)

func node_deselected(node:Node)->void :
	var scope = Profiler.scope(self, "node_deselected", [node])

	selected_nodes.erase(node)

func clear_selected_nodes()->void :
	var scope = Profiler.scope(self, "clear_selected_nodes", [])

	selected_nodes.clear()

func populate_selected_nodes(in_selected_nodes:Array)->void :
	var scope = Profiler.scope(self, "populate_selected_nodes", [in_selected_nodes])

	selected_nodes = in_selected_nodes.duplicate()
	select_nodes(get_root(), selected_nodes)
	ensure_cursor_is_visible()


func select_nodes(tree_item:TreeItem, nodes:Array):
	var scope = Profiler.scope(self, "select_nodes", [tree_item, nodes])

	var node = tree_item.get_metadata(0)
	if node:
		var found_node: = false

		for selected_node in nodes:
			if node == selected_node:
				found_node = true

				tree_item.select(0)

				if tree_item.has_meta("tree_icon_highlight"):
					tree_item.set_icon(0, tree_item.get_meta("tree_icon_highlight"))

		if not found_node:
			tree_item.deselect(0)
			if tree_item.has_meta("tree_icon_highlight"):
				tree_item.set_icon(0, tree_item.get_meta("tree_icon"))

	var next_child = tree_item.get_children()
	var children: = []
	while true:
		if not next_child:
			break
		children.append(next_child)
		next_child = next_child.get_next()

	for child in children:
		select_nodes(child, nodes)


func nodes_created(nodes:Array)->void :
	var scope = Profiler.scope(self, "nodes_created", [nodes])

	update_tree()


func nodes_deleted(nodes:Array)->void :
	var scope = Profiler.scope(self, "nodes_deleted", [nodes])

	update_tree()


func node_moved(node:Node)->void :
	var scope = Profiler.scope(self, "node_moved", [node])

	update_tree()


func nodes_reparented(nodes:Array)->void :
	var scope = Profiler.scope(self, "nodes_reparented", [nodes])

	update_tree()
