class_name TexturePropertyOverlay
extends Control
tool 

export (Array, Resource) var property_textures setget set_property_textures

var workshop_camera:Camera
var current_node:Node = null

func populate_node()->void :
	var scope = Profiler.scope(self, "populate_node", [])

	var hovered_node = WorkshopDirectory.hovered_node().hovered_node
	if hovered_node:
		var group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(hovered_node, true, true)
		if group_ancestor:
			current_node = group_ancestor
		else :
			current_node = hovered_node
	else :
		current_node = null

func set_property_textures(new_property_textures:Array)->void :
	var scope = Profiler.scope(self, "set_property_textures", [new_property_textures])

	for i in range(0, new_property_textures.size()):
		if new_property_textures[i] == null:
			new_property_textures[i] = TextureProperty.new()

	if property_textures != new_property_textures:
		property_textures = new_property_textures

func _process(_delta:float)->void :
	var scope = Profiler.scope(self, "_process", [_delta])

	if visible:
		update()

func _draw()->void :
	var scope = Profiler.scope(self, "_draw", [])

	workshop_camera = WorkshopDirectory.workshop_camera()
	if not workshop_camera:
		return 

	var set_root = WorkshopDirectory.set_root()
	if not set_root:
		return 

	var viewport_size = workshop_camera.get_viewport().size
	var viewport_rect = Rect2(Vector2.ZERO, viewport_size / GraphicsSettings.data.resolution_scale_factor)

	if current_node is BrickHillObject:
		var aabb = current_node.get_bounds()

		var frustum_planes = workshop_camera.get_frustum()

		var world_points: = []
		for i in range(0, 8):
			var object_point = aabb.get_endpoint(i)
			var world_point = current_node.global_transform.basis.orthonormalized().xform(object_point)
			world_point += current_node.global_transform.origin

			world_points.append(world_point)

		var camera_points: = []
		for world_point in world_points:
			if frustum_planes[0].is_point_over(world_point):
				world_point = frustum_planes[0].project(world_point)
			camera_points.append(world_point)

		var screen_rect = null
		for camera_point in camera_points:
			var screen_point = workshop_camera.unproject_position(camera_point)

			screen_point /= GraphicsSettings.data.resolution_scale_factor
			

			if screen_rect == null:
				screen_rect = Rect2(screen_point, Vector2(0, 0))
			else :
				screen_rect = screen_rect.expand(screen_point)

		if not screen_rect:
			return 

		

		for property_texture in property_textures:
			var texture = property_texture.texture
			var viewport_outset = texture.get_size() * 2.0
			var viewport_rect_grown = viewport_rect.grow(max(viewport_outset.x, viewport_outset.y))
			screen_rect = viewport_rect_grown.clip(screen_rect)

			

			var pos = screen_rect.position + screen_rect.size * property_texture.object_offset

			

			if viewport_rect_grown.has_point(pos):
				var _origin_offset = texture.get_size() * property_texture.texture_origin
				var modulate = Color(1, 1, 1, 0.5)
				if current_node.get(property_texture.property_name) == true:
					modulate.a = 1.0
				draw_texture(texture, pos - texture.get_size() * property_texture.texture_origin, modulate)

func viewport_input_mode_changed()->void :
	var scope = Profiler.scope(self, "viewport_input_mode_changed", [])

	var mode = WorkshopDirectory.viewport_input_manager().mode
	visible = mode == ViewportInputManager.Mode.LOCK_ANCHOR
