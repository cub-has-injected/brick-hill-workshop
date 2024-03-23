class_name NativePanorama
extends Resource
tool 

export (Texture) var panorama_texture:Texture setget set_panorama_texture
export (ImageTexture) var icon:ImageTexture

func set_panorama_texture(new_panorama_texture:Texture)->void :
	var scope = Profiler.scope(self, "set_panorama_texture", [new_panorama_texture])

	if panorama_texture != new_panorama_texture:
		panorama_texture = new_panorama_texture
		update_icon()

func update_icon()->void :
	var scope = Profiler.scope(self, "update_icon", [])

	var icon_image = panorama_texture.get_data()
	icon = ImageTexture.new()
	icon.create_from_image(icon_image)
	icon.set_size_override(Vector2(128, 64))
	property_list_changed_notify()
