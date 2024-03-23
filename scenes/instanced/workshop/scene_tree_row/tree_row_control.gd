class_name TreeRow
extends TreeRowBase
tool 

var _has_mouse: = false

func _ready()->void :
	$Visible.connect("toggled", self, "visible_toggled")
	$Lock.connect("toggled", self, "lock_toggled")
	$Anchor.connect("toggled", self, "anchor_toggled")

	connect("mouse_entered", self, "on_mouse_entered")
	connect("mouse_exited", self, "on_mouse_exited")

func _process(_delta:float)->void :
	var global_rect = Rect2(rect_global_position, rect_size)
	var mouse_position = get_viewport().get_mouse_position()
	var new_has_mouse = global_rect.has_point(mouse_position)
	if _has_mouse != new_has_mouse:
		_has_mouse = new_has_mouse
		update()

func _draw()->void :
	$Visible.visible = false
	$Lock.visible = false
	$Anchor.visible = false

	if not is_inside_tree():
		return 

	if not node:
		return 

	var texture:Texture = null
	if node.has_method("get_tree_icon"):
		texture = node.get_tree_icon(selected)
	$Icon.texture = texture

	$Label.text = node.get_name()
	if selected:
		$Label.add_color_override("font_color", Color.white)
	else :
		$Label.add_color_override("font_color", Color.black)

	if not _has_mouse:
		return 

	
	var visible:bool = true
	if node.has_method("is_visible") and not node is SetRoot:
		$Visible.visible = true

		visible = node.is_visible()

		var visible_mod = Color.white
		if not visible:
			visible_mod.a = 0.5

		$Visible.set_block_signals(true)
		$Visible.pressed = visible
		$Visible.modulate = visible_mod
		$Visible.set_block_signals(false)
	else :
		$Visible.visible = false

	
	var locked:bool = false
	if "locked" in node:
		$Lock.visible = true
		locked = node.locked

		var locked_mod = Color.white
		if not locked:
			locked_mod.a = 0.5

		$Lock.set_block_signals(true)
		$Lock.pressed = locked
		$Lock.modulate = locked_mod
		$Lock.set_block_signals(false)
	else :
		$Lock.visible = false

	
	var anchored:bool = false
	if "anchored" in node:
		$Anchor.visible = true
		anchored = node.anchored

		var anchored_mod = Color.white
		if not anchored:
			anchored_mod.a = 0.5

		$Anchor.set_block_signals(true)
		$Anchor.pressed = anchored
		$Anchor.modulate = anchored_mod
		$Anchor.set_block_signals(false)
	else :
		$Anchor.visible = false

class RenameClosure:
	var node:Node

	func _init(in_node:Node)->void :
		node = in_node

	func call_func(new_name:String)->void :
		SetProperty.new(node, "name", new_name).execute()

func _gui_input(event:InputEvent)->void :
	if event is InputEventMouseButton:
		if event.doubleclick:
			var label_rect = $Label.get_rect()
			label_rect.position += rect_position
			emit_signal("show_rename_line_edit", label_rect, $Label.text, RenameClosure.new(node))

func visible_toggled(new_visible:bool)->void :
	SetProperty.new(node, "visible", new_visible).execute()

func lock_toggled(new_locked:bool)->void :
	SetProperty.new(node, "locked", new_locked).execute()

func anchor_toggled(new_anchored:bool)->void :
	SetProperty.new(node, "anchored", new_anchored).execute()
