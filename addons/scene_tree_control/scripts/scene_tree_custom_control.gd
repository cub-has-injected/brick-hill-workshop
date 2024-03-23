class_name SceneTreeCustomControl

var scene_tree_control:Control = null
var custom_column:SceneTreeCustomColumn = null

func _init(in_scene_tree_control:Control, in_custom_column:SceneTreeCustomColumn)->void :
	scene_tree_control = in_scene_tree_control
	custom_column = in_custom_column

func draw(item:TreeItem, rect:Rect2)->void :
	var node = item.get_metadata(0)
	custom_column.draw(scene_tree_control, rect, item, node)

func input(scene_tree_control:Control, event:InputEvent, item:TreeItem, node:Node)->void :
	custom_column.input(scene_tree_control, event, item, node)
