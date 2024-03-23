class_name Scope
extends Reference

var id:int = - 1
var open:bool = false

func close()->void :
	open = false
	Profiler.scope_close(id)

func _notification(what:int)->void :
	if what == NOTIFICATION_PREDELETE:
		if not open:
			return 

		open = false

		if is_instance_valid(Profiler):
			Profiler.scope_close(id)
