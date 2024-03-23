class_name SetGetAction extends ActionData.Base

var target_ref:WeakRef = weakref(null)
var setter:String
var getter:String
var from_value = null
var to_value = null

func _init(in_target:Object, in_setter:String, in_getter:String, in_to_value):
	var scope = Profiler.scope(self, "_init", [in_target, in_setter, in_getter, in_to_value])

	target_ref = weakref(in_target)
	setter = in_setter
	getter = in_getter
	from_value = in_target.call(getter)
	to_value = in_to_value

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (target_ref.get_ref(), "Invalid target")
	assert ( not setter.empty(), "Invalid setter")
	assert ( not getter.empty(), "Invalid getter")

func do():
	var scope = Profiler.scope(self, "do")

	var target = target_ref.get_ref()
	assert (target.call(getter) == from_value, "Action state has been invalidated")
	target.call(setter, to_value)

func undo():
	var scope = Profiler.scope(self, "undo")

	var target = target_ref.get_ref()
	assert (target.call(getter) == to_value, "Action state has been invalidated")
	target.call(setter, from_value)

func _to_string()->String:
	return "SetGet"
