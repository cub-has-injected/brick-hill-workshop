class_name DragDropData

class Base:
	var drop_data:DropData

class Single extends Base:
	var single_drag_data:DragData.Single

	func _init(in_single_drag_data:DragData.Single, in_drop_data:DropData):
		var scope = Profiler.scope(self, "_init", [in_single_drag_data, in_drop_data])

		single_drag_data = in_single_drag_data
		drop_data = in_drop_data

class Multi extends Base:
	var multi_drag_data:DragData.Multi

	func _init(in_multi_drag_data:DragData.Multi, in_drop_data:DropData):
		var scope = Profiler.scope(self, "_init", [in_multi_drag_data, in_drop_data])

		multi_drag_data = in_multi_drag_data
		drop_data = in_drop_data

static func init(drag_data:DragData.Base, drop_data:DropData)->Base:
	if drag_data is DragData.Single:
		return Single.new(drag_data, drop_data)
	elif drag_data is DragData.Multi:
		return Multi.new(drag_data, drop_data)
	return null
