class_name AssignProperty extends ActionData.Base

var target_ref:WeakRef = weakref(null)
var property:String
var from_value = null
var to_value = null

var _late_bind: = false

func _init(in_target:Object, in_property:String, in_to_value = null):
	var scope = Profiler.scope(self, "_init", [in_target, in_property, in_to_value])

	target_ref = weakref(in_target)
	property = in_property
	from_value = in_target[property]
	to_value = in_to_value

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (target_ref.get_ref(), "Invalid target")
	assert ( not property.empty(), "Invalid property")

func execute(in_to_value = ActionData.NoOp)->void :
	var scope = Profiler.scope(self, "execute")

	if not (in_to_value is Object) or (in_to_value is Object and in_to_value != ActionData.NoOp):
		var target = target_ref.get_ref()
		assert (target)
		to_value = in_to_value
		_late_bind = true
	.execute(in_to_value)

func do():
	var scope = Profiler.scope(self, "do")

	var target = target_ref.get_ref()
	assert (_late_bind or target[property] == from_value, "Action state has been invalidated")
	target[property] = to_value

func undo():
	var scope = Profiler.scope(self, "undo")

	var target = target_ref.get_ref()
	assert (_late_bind or target[property] == to_value, "Action state has been invalidated")
	target[property] = from_value

func _to_string()->String:
	return "AssignProperty(%s (%s) => %s)" % [property, from_value, to_value]
