class_name EndCompositeAction extends ActionData.Base


func do()->void :
	var scope = Profiler.scope(self, "do")

func undo()->void :
	var scope = Profiler.scope(self, "undo")

func _to_string()->String:
	return "EndComposite"
