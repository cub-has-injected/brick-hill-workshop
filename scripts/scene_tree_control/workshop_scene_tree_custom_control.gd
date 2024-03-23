class_name WorkshopSceneTreeCustomControl

static func rect_center_offset(source_size:Vector2, target_size:Vector2)->Vector2:

	var size_delta = source_size - target_size
	var offset = size_delta * 0.5
	return offset

static func draw_background(scene_tree_control:Control, rect:Rect2, item:TreeItem)->void :
	if item.is_selected(1):
		scene_tree_control.draw_rect(rect, Color("#00a9fe"))

static func draw_texture_centered(scene_tree_control:Control, texture:Texture, rect:Rect2, modulate:Color = Color.white)->void :
	var size = texture.get_size()
	var offset = rect_center_offset(rect.size, size)
	scene_tree_control.draw_texture(texture, rect.position + offset.round(), modulate)
