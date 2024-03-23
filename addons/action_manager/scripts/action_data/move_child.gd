class_name MoveChildAction extends ActionData.Base

var parent_ref:WeakRef = weakref(null)
var child_ref:WeakRef = weakref(null)
var from_position:int = - 1
var to_position:int = - 1

func _init(in_parent:Node, in_child:Node, in_to_position:int):
	var scope = Profiler.scope(self, "_init", [in_parent, in_child, in_to_position])

	parent_ref = weakref(in_parent)
	child_ref = weakref(in_child)
	from_position = in_child.get_index()
	to_position = in_to_position

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (parent_ref.get_ref(), "Invalid parent")
	assert (child_ref.get_ref(), "Invalid child")
	assert (from_position != - 1, "Invalid 'from' position")
	assert (to_position != - 1, "Invalid 'to' position")

func do():
	var scope = Profiler.scope(self, "do")

	var parent = parent_ref.get_ref()
	var child = child_ref.get_ref()
	
	assert (child in parent.get_children())
	assert (to_position < parent.get_children().size())
	parent.move_child(child, to_position)

func undo():
	var scope = Profiler.scope(self, "undo")

	var parent = parent_ref.get_ref()
	var child = child_ref.get_ref()
	
	assert (child in parent.get_children())
	parent.move_child(child, from_position)

func _to_string()->String:
	return "MoveChild { from: %s, to: %s }" % [from_position, to_position]
