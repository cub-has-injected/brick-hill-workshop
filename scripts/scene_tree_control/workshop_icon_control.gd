class_name WorkshopIconControl
extends SceneTreeCustomColumn

func draw(scene_tree_control:Control, rect:Rect2, item:TreeItem, node:Node)->void :
	var scope = Profiler.scope(self, "draw", [scene_tree_control, rect, item, node])

	WorkshopSceneTreeCustomControl.draw_background(scene_tree_control, rect, item)

	assert (node.has_method("get_tree_icon"))
	var icon_texture: = node.get_tree_icon(item.is_selected(1)) as Texture

	var size = icon_texture.get_size()
	var offset = WorkshopSceneTreeCustomControl.rect_center_offset(rect.size, size)
	offset.x = 4
	scene_tree_control.draw_texture(icon_texture, rect.position + offset.round())
