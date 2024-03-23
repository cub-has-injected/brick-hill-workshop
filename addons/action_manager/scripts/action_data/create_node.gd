class_name CreateNodeAction extends ActionData.Base

var instance:Node = null
var parent_ref:WeakRef = weakref(null)

func _init(in_instance:Node, in_parent:Node):
	var scope = Profiler.scope(self, "_init", [in_instance, in_parent])

	instance = in_instance
	parent_ref = weakref(in_parent)

func validate_state()->void :
	assert (parent_ref.get_ref(), "Invalid parent")

func do():
	var scope = Profiler.scope(self, "do")

	var parent = parent_ref.get_ref()
	parent.add_child(instance, true)

func undo():
	var scope = Profiler.scope(self, "undo")

	assert (instance, "Instance has been invalidated")
	var parent = parent_ref.get_ref()
	parent.remove_child(instance)

func _to_string()->String:
	return "CreateNode"
