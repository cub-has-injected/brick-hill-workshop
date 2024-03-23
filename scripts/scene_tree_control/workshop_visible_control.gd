class_name WorkshopVisibleControl
extends SceneTreeCustomColumn

const VISIBLE_ICON:Texture = preload("res://ui/icons/workshop/tools/unhide.png")
const HIDDEN_ICON:Texture = preload("res://ui/icons/workshop/tools/hide.png")

func draw(scene_tree_control:Control, rect:Rect2, item:TreeItem, node:Node)->void :
	var scope = Profiler.scope(self, "draw", [scene_tree_control, rect, item, node])

	WorkshopSceneTreeCustomControl.draw_background(scene_tree_control, rect, item)

	if node is SetRoot or node is BrickHillGroup:
		return 

	var texture:Texture
	if node.visible:
		texture = VISIBLE_ICON
	else :
		texture = HIDDEN_ICON

	WorkshopSceneTreeCustomControl.draw_texture_centered(scene_tree_control, texture, rect)

func input(scene_tree_control:Control, event:InputEvent, item:TreeItem, node:Node)->void :
	var scope = Profiler.scope(self, "input", [scene_tree_control, event, item, node])

	if node is SetRoot or node is BrickHillGroup:
		return 

	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_LEFT:
				AssignProperty.new(node, "visible", not node.visible).execute()
