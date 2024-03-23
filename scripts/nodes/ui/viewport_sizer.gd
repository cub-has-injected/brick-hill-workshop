class_name ViewportSizer
extends Node
tool 

export (Vector2) var size:Vector2 setget set_size
export (Vector2) var min_size: = Vector2(16, 16)


func set_size(new_size:Vector2)->void :
	var scope = Profiler.scope(self, "set_size", [new_size])

	if size != new_size:
		size = new_size
		if is_inside_tree():
			update_viewport_size()


func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	update_viewport_size()


func update_viewport_size()->void :
	var scope = Profiler.scope(self, "update_viewport_size", [])

	var new_size = size * GraphicsSettings.data.resolution_scale_factor

	if new_size.x < min_size.x:
		new_size.x = min_size.x

	if new_size.y < min_size.y:
		new_size.y = min_size.y

	for child in get_children():
		assert (child is Viewport)
		child.size = new_size
