class_name DragData

class Base:
	pass

class Single extends Base:
	var item:TreeItem

	func _init(in_item:TreeItem):
		var scope = Profiler.scope(self, "_init", [in_item])

		assert (in_item != null)
		item = in_item

class Multi extends Base:
	var items:Array

	func _init(in_selected_items:Array):
		var scope = Profiler.scope(self, "_init", [in_selected_items])

		assert (in_selected_items.size() > 0)
		for item in in_selected_items:
			assert (item != null)
		items = in_selected_items

static func init(items:Array)->Base:
	assert (items.size() > 0)

	if items.size() == 1:
		return Single.new(items[0])
	else :
		return Multi.new(items)
