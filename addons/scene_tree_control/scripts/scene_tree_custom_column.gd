class_name SceneTreeCustomColumn

func draw(scene_tree_control:Control, rect:Rect2, item:TreeItem, node:Node)->void :
	var scope = Profiler.scope(self, "draw", [scene_tree_control, rect, item, node])

	

func input(scene_tree_control:Control, event:InputEvent, item:TreeItem, node:Node)->void :
	var scope = Profiler.scope(self, "input", [scene_tree_control, event, item, node])

	
