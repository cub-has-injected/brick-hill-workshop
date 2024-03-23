class_name SceneTreeControl
extends Tree
tool 

signal node_selected(node)
signal node_deselected(node)

export (NodePath) var target: = NodePath() setget set_target
export (Array) var scene_tree_columns:Array setget set_scene_tree_columns
export (bool) var show_column_titles: = false setget set_show_column_titles

var _scene_tree:SceneTree = null
var _wants_rebuild_tree:bool = true
var _wants_rebuild_columns:bool = true
var _root_node:Node = null
var _custom_controls: = []

func set_target(new_target:NodePath)->void :
	var scope = Profiler.scope(self, "set_target", [new_target])

	if target != new_target:
		target = new_target
		queue_rebuild_tree()

func get_selected_nodes()->Array:
	var scope = Profiler.scope(self, "get_selected_nodes", [])

	var selected_nodes: = []
	var candidate = null
	while true:
		var selected_node = get_next_selected(candidate)
		if not selected_node:
			break
		candidate = selected_node
		selected_nodes.append(candidate.get_metadata(0))

	return selected_nodes





var filter_node_func:FuncRef = funcref(self, "filter_node_impl")
func filter_node(node:Node)->bool:
	var scope = Profiler.scope(self, "filter_node", [node])

	return filter_node_func.call_func(node)

func filter_node_impl(node:Node)->bool:
	var scope = Profiler.scope(self, "filter_node_impl", [node])

	return true

var node_is_selected_func:FuncRef = funcref(self, "node_is_selected_impl")
func node_is_selected(node:Node)->bool:
	var scope = Profiler.scope(self, "node_is_selected", [node])

	return node_is_selected_func.call_func(node)

func node_is_selected_impl(node:Node)->bool:
	var scope = Profiler.scope(self, "node_is_selected_impl", [node])

	return false

var node_accepts_children_func:FuncRef = funcref(self, "node_accepts_children_impl")
func node_accepts_children(node:Node)->bool:
	var scope = Profiler.scope(self, "node_accepts_children", [node])

	return node_accepts_children_func.call_func(node)

func node_accepts_children_impl(node:Node)->bool:
	var scope = Profiler.scope(self, "node_accepts_children_impl", [node])

	return true




func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])


	connect("item_edited", self, "item_edited")

	connect("item_collapsed", self, "item_collapsed")

	connect("multi_selected", self, "multi_selected")

	ActionManager.connect("on_action_do", self, "on_action_do")
	ActionManager.connect("on_action_undo", self, "on_action_undo")

	_scene_tree = get_tree()


	_scene_tree.connect("node_added", self, "check_rebuild")

	_scene_tree.connect("node_removed", self, "check_rebuild")

	_scene_tree.connect("node_renamed", self, "check_rebuild")

	update_column_titles()

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	disconnect("item_edited", self, "item_edited")
	disconnect("item_collapsed", self, "item_collapsed")
	disconnect("multi_selected", self, "multi_selected")

	ActionManager.disconnect("on_action_do", self, "on_action_do")
	ActionManager.disconnect("on_action_undo", self, "on_action_undo")

	if _scene_tree:
		_scene_tree.disconnect("node_added", self, "check_rebuild")
		_scene_tree.disconnect("node_removed", self, "check_rebuild")
		_scene_tree.disconnect("node_renamed", self, "check_rebuild")
		_scene_tree = null

func multi_selected(item:TreeItem, column:int, selected:bool)->void :
	var scope = Profiler.scope(self, "multi_selected", [item, column, selected])

	var node = item.get_metadata(0)
	if selected:
		emit_signal("node_selected", node)
	else :
		emit_signal("node_deselected", node)

func on_action_do(_action:ActionData.Base)->void :
	var scope = Profiler.scope(self, "on_action_do", [_action])

	queue_rebuild_tree()

func on_action_undo(_action:ActionData.Base)->void :
	var scope = Profiler.scope(self, "on_action_undo", [_action])

	queue_rebuild_tree()

func check_rebuild(node:Node)->void :
	var scope = Profiler.scope(self, "check_rebuild", [node])

	if _root_node and _root_node.is_a_parent_of(node):
		queue_rebuild_tree()




func queue_rebuild_tree()->void :
	var scope = Profiler.scope(self, "queue_rebuild_tree", [])

	_wants_rebuild_tree = true

func queue_rebuild_columns()->void :
	var scope = Profiler.scope(self, "queue_rebuild_columns", [])

	_wants_rebuild_columns = true

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	if _wants_rebuild_columns:
		_wants_rebuild_columns = false
		_wants_rebuild_tree = false
		rebuild_columns()
		rebuild_tree()

	if _wants_rebuild_tree:
		_wants_rebuild_tree = false
		rebuild_tree()




func set_scene_tree_columns(new_scene_tree_columns:Array)->void :
	var scope = Profiler.scope(self, "set_scene_tree_columns", [new_scene_tree_columns])

	if scene_tree_columns.size() != new_scene_tree_columns.size():
		scene_tree_columns.resize(new_scene_tree_columns.size())
		queue_rebuild_columns()

	for i in range(0, new_scene_tree_columns.size()):
		var new_column = new_scene_tree_columns[i]
		if not new_column is SceneTreeColumn:
			new_column = SceneTreeColumn.new()

		if scene_tree_columns[i] != new_column:
			scene_tree_columns[i] = new_column
			queue_rebuild_columns()

func set_show_column_titles(new_show_column_titles:bool)->void :
	var scope = Profiler.scope(self, "set_show_column_titles", [new_show_column_titles])

	if show_column_titles != new_show_column_titles:
		show_column_titles = new_show_column_titles
		update_column_titles()

func update_column_titles()->void :
		var scope = Profiler.scope(self, "update_column_titles", [])

		set_column_titles_visible(show_column_titles)

func rebuild_columns()->void :
	var scope = Profiler.scope(self, "rebuild_columns", [])

	columns = scene_tree_columns.size()

	for i in range(0, scene_tree_columns.size()):
		var column = scene_tree_columns[i]
		set_column_title(i, column.title)
		set_column_min_width(i, column.min_width)
		set_column_expand(i, column.expand)




func rebuild_tree()->void :
	var scope = Profiler.scope(self, "rebuild_tree", [])

	print("Rebuild tree")

	clear()
	_custom_controls.clear()

	if target.is_empty():
		return 

	_custom_controls.resize(scene_tree_columns.size())
	for i in range(0, scene_tree_columns.size()):
		var column = scene_tree_columns[i]
		if column.mode == SceneTreeColumn.Mode.CUSTOM:
			if column.custom_control:
				var control = column.custom_control.new()
				_custom_controls[i] = SceneTreeCustomControl.new(self, control)

	_root_node = get_node(target)
	assert (_root_node, "SceneTreeControl target not valid")

	traverse(_root_node)

func has_nodes(node:Node)->bool:
	var scope = Profiler.scope(self, "has_nodes", [node])

	var has_nodes = filter_node(node)
	for child in node.get_children():
		has_nodes = has_nodes or has_nodes(child)
	return has_nodes

func traverse(node:Node, tree_item:TreeItem = null)->void :
	var scope = Profiler.scope(self, "traverse", [node, tree_item])

	if not has_nodes(node):
		for child_node in node.get_children():
			traverse(child_node, tree_item)
	else :
		var item = create_item(tree_item)
		item.set_metadata(0, node)
		item.set_collapsed(node.is_displayed_folded())

		for i in range(0, scene_tree_columns.size()):
			var column = scene_tree_columns[i]
			item.set_selectable(i, column.selectable)
			item.set_editable(i, column.editable)

			if column.selectable:
				if node_is_selected(node):
					item.select(i)

			match column.mode:
				SceneTreeColumn.Mode.STRING:
					item.set_cell_mode(i, TreeItem.CELL_MODE_STRING)
					if node.has_method(column.getter):
						item.set_text(i, node.call(column.getter))
				SceneTreeColumn.Mode.RANGE:
					item.set_cell_mode(i, TreeItem.CELL_MODE_RANGE)
					if node.has_method(column.getter):
						item.set_range(i, node.call(column.getter))
				SceneTreeColumn.Mode.CHECK:
					item.set_cell_mode(i, TreeItem.CELL_MODE_CHECK)
					if node.has_method(column.getter):
						item.set_checked(i, node.call(column.getter))
				SceneTreeColumn.Mode.ICON:
					item.set_cell_mode(i, TreeItem.CELL_MODE_ICON)
					if node.has_method(column.getter):
						item.set_icon(i, node.call(column.getter))
				SceneTreeColumn.Mode.CUSTOM:
					item.set_cell_mode(i, TreeItem.CELL_MODE_CUSTOM)
					item.set_custom_as_button(i, column.custom_as_button)
					item.set_custom_bg_color(i, column.custom_bg_color)
					item.set_custom_color(i, column.custom_color)
					if _custom_controls[i]:
						item.set_custom_draw(i, _custom_controls[i], "draw")

		for child_node in node.get_children():
			traverse(child_node, item)




func item_edited()->void :
	var scope = Profiler.scope(self, "item_edited", [])

	var selected_item = get_selected()
	if not selected_item:
		return 

	var selected_column = get_selected_column()
	if selected_column == - 1:
		return 

	var column = scene_tree_columns[selected_column]
	if column.mode != SceneTreeColumn.Mode.STRING:
		return 

	var selected_node = selected_item.get_metadata(0)
	var edited_string = selected_item.get_text(selected_column)
	SetGetAction.new(selected_node, column.setter, column.getter, edited_string).execute()




func item_collapsed(item:TreeItem)->void :
	var scope = Profiler.scope(self, "item_collapsed", [item])

	var node: = item.get_metadata(0) as Node
	node.set_display_folded(item.is_collapsed())




func _gui_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_gui_input", [event])

	if event is InputEventMouse:
		var local_mouse_position = get_local_mouse_position()

		var item = get_item_at_position(local_mouse_position)
		if not item:
			return 

		var node = item.get_metadata(0)

		var column = get_column_at_position(local_mouse_position)
		if column == - 1:
			return 

		var scene_tree_column = scene_tree_columns[column]
		var custom_control = _custom_controls[column]

		if scene_tree_column.mode == SceneTreeColumn.Mode.CHECK:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT and event.pressed:
					SetGetAction.new(node, scene_tree_column.setter, scene_tree_column.getter, not node.call(scene_tree_column.getter)).execute()
		elif scene_tree_column.mode == SceneTreeColumn.Mode.CUSTOM:
			if custom_control:
				custom_control.input(self, event, item, node)




func get_drag_data(position:Vector2):
	var scope = Profiler.scope(self, "get_drag_data", [position])

	var selected_items: = []

	var candidate = get_next_selected(null)
	while true:
		if not candidate:
			break
		selected_items.append(candidate)
		candidate = get_next_selected(candidate)

	if selected_items.size() == 0:
		return null

	var hovered_item = get_item_at_position(position)
	if not hovered_item in selected_items:
		return 

	if not hovered_item.is_selectable(get_column_at_position(position)):
		return 

	drop_mode_flags = DROP_MODE_ON_ITEM | DROP_MODE_INBETWEEN
	return DragData.init(selected_items)

func can_drop_data(position:Vector2, data)->bool:
	var scope = Profiler.scope(self, "can_drop_data", [position, data])

	if not data is DragData.Base:
		return false

	if not get_item_at_position(position):
		return false

	return true

func drop_data(position:Vector2, drag_data:DragData.Base)->void :
	var scope = Profiler.scope(self, "drop_data", [position, drag_data])

	var drop_item = get_item_at_position(position)
	var drop_section = get_drop_section_at_position(position)
	var drop_data = DropData.new(drop_item, drop_section)

	process_drag_drop_data(DragDropData.init(drag_data, drop_data))

func process_drag_drop_data(data:DragDropData.Base)->void :
	var scope = Profiler.scope(self, "process_drag_drop_data", [data])

	if data is DragDropData.Single:
		process_single_drag_drop_data(data)
	elif data is DragDropData.Multi:
		process_multi_drag_drop_data(data)

func process_single_drag_drop_data(data:DragDropData.Single)->void :
	var scope = Profiler.scope(self, "process_single_drag_drop_data", [data])

	var drop_node = data.drop_data.item.get_metadata(0)
	var drop_section = data.drop_data.drop_section
	var drag_node = data.single_drag_data.item.get_metadata(0)

	var action = new_action_data(drag_node, drop_node, drop_section)
	if action:
		action.execute()

func process_multi_drag_drop_data(data:DragDropData.Multi)->void :
	var scope = Profiler.scope(self, "process_multi_drag_drop_data", [data])

	var drop_node = data.drop_data.item.get_metadata(0)
	var drop_section = data.drop_data.drop_section

	var drag_nodes: = []
	for item in data.multi_drag_data.items:
		drag_nodes.append(item.get_metadata(0))

	BeginCompositeAction.new().execute()

	var index = - 1
	for drag_node in drag_nodes:
		var action = new_action_data(drag_node, drop_node, drop_section)

		if action is MoveChildAction:
			if index == - 1:
				index = action.to_position
			else :
				action.to_position = index

			if action.child_ref.get_ref().get_index() >= index:
				index += 1
		elif action is ReparentChildAction:
			if index == - 1:
				index = action.to_position
			else :
				action.to_position = index

			index += 1
		else :
			continue

		action.execute()

	EndCompositeAction.new().execute()

func new_action_data(drag_node:Node, drop_node:Node, drop_section:int)->ActionData.Base:
	var scope = Profiler.scope(self, "new_action_data", [drag_node, drop_node, drop_section])

	
	if drag_node == drop_node:
		return MoveChildAction.new(drag_node.get_parent(), drag_node, drag_node.get_index())

	
	if drag_node.is_a_parent_of(drop_node):
		return null

	
	if drop_node == _root_node and drop_section < 0:
		return null

	
	if drag_node.get_parent() == drop_node:
		match drop_section:
			- 1:
				
				return ReparentChildAction.new(drag_node.get_parent(), drop_node.get_parent(), drag_node, drop_node.get_index(), ["name", "global_transform"])
			0:
				
				return null
			1:
				if drag_node.get_index() != 0:
					
					return MoveChildAction.new(drag_node.get_parent(), drag_node, 0)
		return null

	
	if drag_node.get_parent() == drop_node.get_parent():
		
		if node_accepts_children(drop_node):
			if drop_section == 0 or (drop_node.get_child_count() > 0 and drop_section > 0):
				return ReparentChildAction.new(drag_node.get_parent(), drop_node, drag_node, 0, ["name", "global_transform"])

		var drag_index = drag_node.get_index()
		var drop_index = drop_node.get_index()

		
		if drop_index + drop_section == drag_index:
			return null

		var to_position = drop_index

		var index_delta = drop_index - drag_index
		if index_delta < 0:
			to_position += max(drop_section, 0)
		elif index_delta > 0:
			to_position += min(drop_section, 0)

		return MoveChildAction.new(drag_node.get_parent(), drag_node, to_position)

	
	if node_accepts_children(drop_node):
		if drop_section == 0 or (drop_node.get_child_count() > 0 and drop_section > 0):
			return ReparentChildAction.new(drag_node.get_parent(), drop_node, drag_node, 0, ["name", "global_transform"])

	
	return ReparentChildAction.new(drag_node.get_parent(), drop_node.get_parent(), drag_node, ["name", "global_transform"])
