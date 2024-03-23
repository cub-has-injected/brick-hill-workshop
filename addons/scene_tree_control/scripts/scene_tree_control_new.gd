class_name SceneTreeControlNew
extends Tree
tool 

signal node_selected(node)
signal node_deselected(node)

export (NodePath) var root_node: = NodePath() setget set_root_node
export (PackedScene) var custom_control_scene:PackedScene setget set_custom_control_scene

var _scene_tree:SceneTree = null
var _root_node:Node = null

var _tree_items: = {}

var _free_control_pool: = []
var _used_control_pool: = {}

var _control_root:Control
var _rename_line_edit:LineEdit

func set_root_node(new_root_node:NodePath)->void :
	if root_node != new_root_node:
		root_node = new_root_node
		if is_inside_tree():
			rebuild_tree()

func set_custom_control_scene(new_custom_control_scene:PackedScene)->void :
	if custom_control_scene != new_custom_control_scene:
		custom_control_scene = new_custom_control_scene

func get_selected_nodes()->Array:
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
	return false

var node_accepts_children_func:FuncRef = funcref(self, "node_accepts_children_impl")
func node_accepts_children(node:Node)->bool:
	var scope = Profiler.scope(self, "node_accepts_children", [node])
	return node_accepts_children_func.call_func(node)

func node_accepts_children_impl(node:Node)->bool:
	var scope = Profiler.scope(self, "node_accepts_children_impl", [node])
	return true




func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	for child in get_children():
		if child.has_meta("scene_tree_control_child"):
			remove_child(child)
			child.queue_free()

	_control_root = Control.new()
	_control_root.mouse_filter = MOUSE_FILTER_IGNORE
	_control_root.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	_control_root.set_meta("scene_tree_control_child", true)
	add_child(_control_root)

	_rename_line_edit = LineEdit.new()
	_rename_line_edit.visible = false
	_rename_line_edit.connect("text_entered", self, "run_submit_callback")
	_rename_line_edit.connect("focus_exited", _rename_line_edit, "set_visible", [false])
	_rename_line_edit.set_meta("scene_tree_control_child", true)
	add_child(_rename_line_edit)

	columns = 1


	connect("item_collapsed", self, "item_collapsed")

	connect("multi_selected", self, "multi_selected")

	ActionManager.connect("on_action_do", self, "on_action_do")
	ActionManager.connect("on_action_undo", self, "on_action_undo")

	_scene_tree = get_tree()

	_scene_tree.connect("node_added", self, "on_node_added")

	_scene_tree.connect("node_removed", self, "on_node_removed")

func _ready()->void :
	var scope = Profiler.scope(self, "_ready")
	rebuild_tree()

func _gui_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_gui_input", [event])

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.doubleclick:
			var item = get_item_at_position(get_local_mouse_position())
			if item in _used_control_pool:
				var control = _used_control_pool[item]
				if control.has_method("_gui_input"):
					control._gui_input(event)

		if _rename_line_edit.visible:
			if (event.button_index == BUTTON_WHEEL_UP
			 or event.button_index == BUTTON_WHEEL_DOWN):
				grab_focus()

var _line_edit_submit_callback:Object = null
func show_rename_line_edit(rect:Rect2, text:String, submit_callback:Object)->void :
	var scope = Profiler.scope(self, "show_rename_line_edit", [rect, text, submit_callback])

	_line_edit_submit_callback = submit_callback
	_rename_line_edit.rect_position = rect.position
	_rename_line_edit.rect_size = rect.size
	_rename_line_edit.text = text
	_rename_line_edit.visible = true
	_rename_line_edit.grab_focus()
	_rename_line_edit.select_all()

func run_submit_callback(new_text:String)->void :
	var scope = Profiler.scope(self, "run_submit_callback", [new_text])

	_line_edit_submit_callback.call_func(new_text)
	_line_edit_submit_callback = null
	grab_focus()

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree")

	disconnect("item_collapsed", self, "item_collapsed")
	disconnect("multi_selected", self, "multi_selected")

	ActionManager.disconnect("on_action_do", self, "on_action_do")
	ActionManager.disconnect("on_action_undo", self, "on_action_undo")

	if _scene_tree:
		_scene_tree.disconnect("node_added", self, "on_node_added")
		_scene_tree.disconnect("node_removed", self, "on_node_removed")
		_scene_tree = null

func multi_selected(item:TreeItem, column:int, selected:bool)->void :
	var scope = Profiler.scope(self, "multi_selected", [column, selected])

	var node = item.get_metadata(0)
	if selected:
		emit_signal("node_selected", node)
	else :
		emit_signal("node_deselected", node)

func move_tree_item_child(parent_item:TreeItem, child_item:TreeItem, to:int)->void :
	var scope = Profiler.scope(self, "move_tree_item_child", [parent_item, child_item, to])

	var from:int

	var child_items: = []
	var candidate = parent_item.get_children()
	while true:
		if candidate == child_item:
			from = child_items.size()
		child_items.append(candidate)
		candidate = candidate.get_next()
		if not candidate:
			break

	if from > to:
		for i in range(to, child_items.size()):
			var item = child_items[i]
			if item == child_item:
				continue
			item.move_to_bottom()
	elif from < to:
		var indices = range(0, min(to + 1, child_items.size()))
		indices.invert()
		for i in indices:
			var item = child_items[i]
			if item == child_item:
				continue
			item.move_to_top()

	child_item.select(0)

	update()

func on_action_do(action:ActionData.Base)->void :
	var scope = Profiler.scope(self, "on_action_do", [action])

	if action is MoveChildAction:
		var from:int = action.from_position
		var to:int = action.to_position

		var parent = action.parent_ref.get_ref()
		var child = action.child_ref.get_ref()

		for sibling in parent.get_children():
			var index = sibling.get_index()

			if not filter_node(sibling):
				if index < from:
					from -= 1

				if index < to:
					to -= 1

		var parent_item = _tree_items[parent]
		var child_item = _tree_items[child]

		print("Do MoveChildAction. Moving %s from %s to %s in %s" % [child_item, from, to, parent_item])
		move_tree_item_child(parent_item, child_item, to)
	elif action is SetProperty:
		update()

func on_action_undo(action:ActionData.Base)->void :
	var scope = Profiler.scope(self, "on_action_undo", [action])

	if action is MoveChildAction:
		var from:int = action.from_position
		var to:int = action.to_position

		var parent = action.parent_ref.get_ref()
		var child = action.child_ref.get_ref()

		for sibling in parent.get_children():
			var index = sibling.get_index()

			if not filter_node(sibling):
				if index < from:
					from -= 1

				if index < to:
					to -= 1

		var parent_item = _tree_items[parent]
		var child_item = _tree_items[child]

		print("Undo MoveChildAction. Moving %s from %s to %s in %s" % [child_item, to, from, parent_item])
		move_tree_item_child(parent_item, child_item, from)
	elif action is SetProperty:
		update()

func on_node_added(node:Node)->void :
	var scope = Profiler.scope(self, "on_node_added", [node])

	if not filter_node(node):
		return 

	var parent = node.get_parent()

	if not parent in _tree_items:
		return 

	var parent_item = _tree_items[parent]
	var child_index = node.get_index()

	var item = create_node_item(node, parent_item, child_index)

func on_node_removed(node:Node)->void :
	var scope = Profiler.scope(self, "on_node_removed", [node])

	if not filter_node(node):
		return 

	if node in _tree_items:
		var tree_item = _tree_items[node]

		return_custom_control(tree_item)

		if node in _tree_items:
			if _tree_items[node]:
				_tree_items[node].free()
			_tree_items.erase(node)

		update()

func select_node(node:Node)->void :
	var scope = Profiler.scope(self, "select_node", [node])

	if node in _tree_items:
		var tree_item = _tree_items[node]
		tree_item.select(0)

func deselect_node(node:Node)->void :
	var scope = Profiler.scope(self, "deselect_node", [node])

	if node in _tree_items:
		var tree_item = _tree_items[node]
		tree_item.deselect(0)




func rebuild_tree()->void :
	var scope = Profiler.scope(self, "rebuild_tree")

	_clear_control_pool()
	_tree_items.clear()
	clear()

	if root_node.is_empty():
		return 

	_root_node = get_node(root_node)
	assert (_root_node, "SceneTreeControl root_node not valid")

	traverse(_root_node)

func create_node_item(node:Node, parent:TreeItem = null, index:int = - 1)->TreeItem:
	var scope = Profiler.scope(self, "create_node_item", [node, parent, index])

	var item = create_item(parent, index)
	item.set_metadata(0, node)
	item.set_collapsed(node.is_displayed_folded())

	item.set_cell_mode(0, TreeItem.CELL_MODE_CUSTOM)
	item.set_custom_draw(0, self, "draw_custom")

	_tree_items[node] = item
	return item

func traverse(node:Node, parent:TreeItem = null)->void :
	var scope = Profiler.scope(self, "traverse", [node, parent])

	if not filter_node(node):
		for child_node in node.get_children():
			traverse(child_node, parent)
	else :
		var item = create_node_item(node, parent)
		for child_node in node.get_children():
			traverse(child_node, item)

func draw_custom(item:TreeItem, rect:Rect2)->void :
	var scope = Profiler.scope(self, "draw_custom", [item, rect])

	_set_drawing(true)

	var control = take_custom_control(item)
	control.rect_position = rect.position
	control.rect_size = rect.size
	control.node = item.get_metadata(0)
	control.selected = item.is_selected(0)

var _drawing: = false

func _set_drawing(new_drawing:bool)->void :
	var scope = Profiler.scope(self, "_set_drawing", [new_drawing])

	if _drawing != new_drawing:
		if not _drawing and new_drawing:
			draw_begin()

		if _drawing and not new_drawing:
			draw_end()
		_drawing = new_drawing

func _clear_control_pool()->void :
	var scope = Profiler.scope(self, "_clear_control_pool")

	for tree_item in _used_control_pool:
		var control = _used_control_pool[tree_item]
		_control_root.remove_child(control)
		_free_control_pool.append(control)
	_used_control_pool.clear()

func _draw()->void :
	var scope = Profiler.scope(self, "_draw")
	_set_drawing(false)

func draw_begin()->void :
	var scope = Profiler.scope(self, "draw_begin")
	_clear_control_pool()

func draw_end()->void :
	var scope = Profiler.scope(self, "draw_end")

func take_custom_control(tree_item:TreeItem)->Control:
	var scope = Profiler.scope(self, "take_custom_control", [tree_item])

	var control:Control = null
	if _free_control_pool.empty():
		control = custom_control_scene.instance()
		control.connect("show_rename_line_edit", self, "show_rename_line_edit")
	else :
		control = _free_control_pool.pop_front()

	_control_root.add_child(control)
	_used_control_pool[tree_item] = control

	return control

func return_custom_control(tree_item:TreeItem)->void :
	var scope = Profiler.scope(self, "return_custom_control", [tree_item])

	if tree_item in _used_control_pool:
		var control = _used_control_pool[tree_item]
		_control_root.remove_child(control)
		_used_control_pool.erase(tree_item)
		_free_control_pool.append(control)




func item_collapsed(item:TreeItem)->void :
	var scope = Profiler.scope(self, "item_collapsed", [item])

	var node: = item.get_metadata(0) as Node
	node.set_display_folded(item.is_collapsed())




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
	var scope = Profiler.scope(self, "drop_data", [data])

	if data is DragDropData.Single:
		process_single_drag_drop_data(data)
	elif data is DragDropData.Multi:
		process_multi_drag_drop_data(data)

func process_single_drag_drop_data(data:DragDropData.Single)->void :
	var scope = Profiler.scope(self, "process_single_drag_drop_data", [data])

	var drop_node = data.drop_data.item.get_metadata(0)
	var drop_section = data.drop_data.drop_section
	var drag_node = data.single_drag_data.item.get_metadata(0)

	var actions = new_action_data(drag_node, drop_node, drop_section)
	for action in actions:
		action.execute(ActionData.NoOp.new())

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
		var actions = new_action_data(drag_node, drop_node, drop_section)
		for action in actions:
			"\n			if action is MoveChildAction:\n				if index == -1:\n					index = action.to_position\n				else:\n					action.to_position = index\n\n				if action.child_ref.get_ref().get_index() >= index:\n					index += 1\n\n				index += 1\n			"
			action.execute()

	EndCompositeAction.new().execute()

func new_action_data(drag_node:Node, drop_node:Node, drop_section:int)->Array:
	var scope = Profiler.scope(self, "new_action_data", [drag_node, drop_node, drop_section])

	
	if drag_node == drop_node:
		return [MoveChildAction.new(drag_node.get_parent(), drag_node, drag_node.get_index())]

	
	if drag_node.is_a_parent_of(drop_node):
		return []

	
	if drop_node == _root_node and drop_section < 0:
		return []

	
	if drag_node.get_parent() == drop_node:
		match drop_section:
			- 1:
				
				return [
					BeginCompositeAction.new(), 
					MoveChildAction.new(drag_node.get_parent(), drag_node, drag_node.get_index()), 
					ReparentChildAction.new(drag_node.get_parent(), drop_node.get_parent(), drag_node, ["name", "global_transform"]), 
					MoveChildAction.new(drop_node.get_parent(), drag_node, drop_node.get_index()), 
					EndCompositeAction.new()
				]
			0:
				
				return []
			1:
				if drag_node.get_index() != 0:
					
					return [MoveChildAction.new(drag_node.get_parent(), drag_node, 0)]
		return []

	
	if drag_node.get_parent() == drop_node.get_parent():
		
		if node_accepts_children(drop_node):
			if drop_section == 0 or (drop_node.get_child_count() > 0 and drop_section > 0):
				return [
					BeginCompositeAction.new(), 
					MoveChildAction.new(drag_node.get_parent(), drag_node, drag_node.get_index()), 
					ReparentChildAction.new(drag_node.get_parent(), drop_node, drag_node, ["name", "global_transform"]), 
					MoveChildAction.new(drop_node, drag_node, 0), 
					EndCompositeAction.new()
				]

		var drag_index = drag_node.get_index()
		var drop_index = drop_node.get_index()

		
		if drop_index + drop_section == drag_index:
			return []

		var to_position = drop_index

		var index_delta = drop_index - drag_index
		if index_delta < 0:
			to_position += max(drop_section, 0)
		elif index_delta > 0:
			to_position += min(drop_section, 0)

		return [MoveChildAction.new(drag_node.get_parent(), drag_node, to_position)]

	
	if node_accepts_children(drop_node):
		if drop_section == 0 or (drop_node.get_child_count() > 0 and drop_section > 0):
			return [
				BeginCompositeAction.new(), 
				MoveChildAction.new(drag_node.get_parent(), drag_node, drag_node.get_index()), 
				ReparentChildAction.new(drag_node.get_parent(), drop_node, drag_node, ["name", "global_transform"]), 
				MoveChildAction.new(drop_node, drag_node, 0), 
				EndCompositeAction.new()
			]

	
	return [
		BeginCompositeAction.new(), 
		MoveChildAction.new(drag_node.get_parent(), drag_node, drag_node.get_index()), 
		ReparentChildAction.new(drag_node.get_parent(), drop_node.get_parent(), drag_node, ["name", "global_transform"]), 
		MoveChildAction.new(drop_node.get_parent(), drag_node, drop_node.get_index() + max(sign(drop_section + 1), 0)), 
		EndCompositeAction.new()
	]
