class_name SceneTreeCustomControlNew
extends Resource
tool 

func draw(scene_tree_control:Tree, item:TreeItem, rect:Rect2, node:Node)->void :
	var scope = Profiler.scope(self, "draw", [scene_tree_control, item, rect, node])

	pass

func input(scene_tree_control:Tree, event:InputEvent, item:TreeItem, node:Node)->void :
	var scope = Profiler.scope(self, "input", [scene_tree_control, event, item, node])

	pass
