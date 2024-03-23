class_name BrickHillSticker
extends BrickHillObject
tool 

export (BrickHillBrickObject.MaterialType) var material = BrickHillBrickObject.MaterialType.TEST setget set_material
export (Color) var color = Color.white setget set_color
export (float) var roughness = 1.0 setget set_roughness
export (float) var metallic = 0.0 setget set_metallic

var deferred_decal:DeferredDecal

func set_material(new_material:int)->void :
	var scope = Profiler.scope(self, "set_material", [new_material])

	if material != new_material:
		material = new_material
		deferred_decal.decal_albedo = BrickHillResources.MATERIAL_ALBEDO_TEXTURES.values()[material]
		deferred_decal.decal_normal = BrickHillResources.MATERIAL_NORMAL_TEXTURES.values()[material]

func set_color(new_color:Color)->void :
	var scope = Profiler.scope(self, "set_color", [new_color])

	if color != new_color:
		color = new_color
		deferred_decal.albedo = color

func set_roughness(new_roughness:float)->void :
	var scope = Profiler.scope(self, "set_roughness", [new_roughness])

	if roughness != new_roughness:
		roughness = new_roughness
		deferred_decal.roughness = roughness

func set_metallic(new_metallic:float)->void :
	var scope = Profiler.scope(self, "set_metallic", [new_metallic])

	if metallic != new_metallic:
		metallic = new_metallic
		deferred_decal.metallic = metallic

func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Sticker"

func size_changed()->void :
	var scope = Profiler.scope(self, "size_changed")

	deferred_decal.scale = size * 0.5

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	for child in get_children():
		if child.has_meta("sticker_child"):
			remove_child(child)
			child.queue_free()

	deferred_decal = DeferredDecal.new()
	deferred_decal.set_meta("sticker_child", true)
	deferred_decal.scale = Vector3(0.5, 0.5, 0.5)
	add_child(deferred_decal)

func get_tree_icon(highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon", [highlight])

	return BrickHillResources.ICONS.tree_highlight_sticker if highlight else BrickHillResources.ICONS.tree_sticker

func freeze()->void :
	var scope = Profiler.scope(self, "freeze")

	.freeze()
	deferred_decal.draw_debug = true

func unfreeze()->void :
	var scope = Profiler.scope(self, "unfreeze")

	.unfreeze()
	deferred_decal.draw_debug = false

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Sticker"] = {
		"Appearance":[
			"material", 
			"color", 
			"roughness", 
			"metallic"
		]
	}
	return categories
