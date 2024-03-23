class_name ActionData

class NoOp:
	pass

class Base:
	func execute(_data = NoOp)->void :
		var scope = Profiler.scope(self, "execute", [_data])
		ActionManager.execute_action(self)

	func validate_state()->void :
		var scope = Profiler.scope(self, "validate_state")
		
		pass

	func do()->void :
		var scope = Profiler.scope(self, "do")
		
		breakpoint 

	func undo()->void :
		var scope = Profiler.scope(self, "undo")
		
		breakpoint 

	func _to_string()->String:
		return "ActionData.Base"
