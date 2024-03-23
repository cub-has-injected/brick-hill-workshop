class_name SetProperty extends ActionData.Base

var target_ref:WeakRef = weakref(null)
var property:String
var from_value = null
var to_value = null

func _init(in_target:Object, in_property:String, in_to_value):
	var scope = Profiler.scope(self, "_init", [in_target, in_property, in_to_value])

	target_ref = weakref(in_target)
	property = in_property
	from_value = in_target.get(property)
	to_value = in_to_value

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (target_ref.get_ref(), "Invalid target")
	assert ( not property.empty(), "Invalid property")

func do():
	var scope = Profiler.scope(self, "do")

	var target = target_ref.get_ref()
	target.set(property, to_value)

func undo():
	var scope = Profiler.scope(self, "undo")

	var target = target_ref.get_ref()
	target.set(property, from_value)

func _to_string()->String:
	return "SetProperty"
