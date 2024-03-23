class_name DestroyNodeAction extends ActionData.Base

var target_ref:WeakRef = weakref(null)
var parent_ref:WeakRef = weakref(null)
var cached_properties:PropertyCache = null

var _cached_target:Node = null

func _init(in_target:Node, in_cached_properties:PoolStringArray = PoolStringArray()):
	var scope = Profiler.scope(self, "_init", [in_target, in_cached_properties])

	target_ref = weakref(in_target)
	parent_ref = weakref(in_target.get_parent())
	if not in_cached_properties.empty():
		cached_properties = PropertyCache.new(in_target, in_cached_properties)

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (target_ref.get_ref(), "Invalid target")
	assert (parent_ref.get_ref(), "Invalid parent")

func do():
	var scope = Profiler.scope(self, "do")

	var target = target_ref.get_ref()
	var parent = parent_ref.get_ref()
	parent.remove_child(target)
	_cached_target = target

func undo():
	var scope = Profiler.scope(self, "undo")

	assert (_cached_target, "Cached target has been invalidated")
	var parent = parent_ref.get_ref()
	parent.add_child(_cached_target, true)

	if cached_properties:
		cached_properties.apply(_cached_target)

	_cached_target = null

func _to_string()->String:
	return "DestroyNode"
