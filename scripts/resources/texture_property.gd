class_name TextureProperty
extends Resource
tool 

export (String) var property_name:String
export (Texture) var texture:Texture
export (Vector2) var texture_origin:Vector2
export (Vector2) var object_offset:Vector2

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	if resource_name.empty():
		resource_name = "Texture Property"
