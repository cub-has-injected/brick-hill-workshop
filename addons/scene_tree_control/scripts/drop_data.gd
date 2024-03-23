class_name DropData

var item:TreeItem
var drop_section:int

func _init(in_item:TreeItem, in_drop_section:int):
	var scope = Profiler.scope(self, "_init", [in_item, in_drop_section])

	item = in_item
	drop_section = in_drop_section
