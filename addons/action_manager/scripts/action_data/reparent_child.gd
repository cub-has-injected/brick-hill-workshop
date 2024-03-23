class_name ReparentChildAction extends ActionData.Base

var from_parent_ref:WeakRef = weakref(null)
var to_parent_ref:WeakRef = weakref(null)
var child_ref:WeakRef = weakref(null)
var cached_properties:PropertyCache = null

func _init(in_from_parent:Node, in_to_parent:Node, in_child:Node, in_cached_properties:PoolStringArray = PoolStringArray()):
	var scope = Profiler.scope(self, "_init", [in_from_parent, in_to_parent, in_child, in_cached_properties])

	from_parent_ref = weakref(in_from_parent)
	to_parent_ref = weakref(in_to_parent)
	child_ref = weakref(in_child)
	if not in_cached_properties.empty():
		cached_properties = PropertyCache.new(in_child, in_cached_properties)

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (from_parent_ref.get_ref(), "Invalid 'from' parent")
	assert (to_parent_ref.get_ref(), "Invalid 'to' parent")
	assert (child_ref.get_ref(), "Invalid child")

func do()->void :
	var scope = Profiler.scope(self, "do")

	var from_parent = from_parent_ref.get_ref()
	var to_parent = to_parent_ref.get_ref()
	var child = child_ref.get_ref()

	var trx
	if "global_transform" in child:
		trx = child.global_transform
	from_parent.remove_child(child)
	to_parent.add_child(child, true)
	if "global_transform" in child:
		child.global_transform = trx

	if cached_properties:
		cached_properties.apply(child)

func undo()->void :
	var scope = Profiler.scope(self, "undo")

	var from_parent = from_parent_ref.get_ref()
	var to_parent = to_parent_ref.get_ref()
	var child = child_ref.get_ref()

	var trx
	if "global_transform" in child:
		trx = child.global_transform
	to_parent.remove_child(child)
	from_parent.add_child(child, true)
	if "global_transform" in child:
		child.global_transform = trx

	if cached_properties:
		cached_properties.apply(child)

func _to_string()->String:
	return "ReparentChild"
