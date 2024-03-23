class_name CallMethod extends ActionData.Base

var target_ref:WeakRef = weakref(null)
var do_method:String
var undo_method:String
var do_args: = []
var undo_args: = []

func _init(in_target:Object, in_do_method:String, in_undo_method:String, in_do_args:Array, in_undo_args:Array):
	var scope = Profiler.scope(self, "_init", [in_target, in_do_method, in_undo_method, in_do_args, in_undo_args])

	target_ref = weakref(in_target)
	do_method = in_do_method
	undo_method = in_undo_method
	do_args = in_do_args
	undo_args = in_undo_args

func validate_state()->void :
	var scope = Profiler.scope(self, "validate_state")

	assert (target_ref.get_ref(), "Invalid target")
	assert ( not do_method.empty(), "Invalid do method")
	assert ( not undo_method.empty(), "Invalid undo method")

func do():
	var scope = Profiler.scope(self, "do")

	var target = target_ref.get_ref()
	target.callv(do_method, do_args)

func undo():
	var scope = Profiler.scope(self, "undo")

	var target = target_ref.get_ref()
	target.callv(undo_method, undo_args)

func _to_string()->String:
	return "CallMethod"
