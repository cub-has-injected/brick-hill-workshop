class_name BrickHillGlue
extends BrickHillGroup
tool 

export (bool) var merge_collisions: = true

func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Glue"

func get_aabb_color()->Color:
	var scope = Profiler.scope(self, "get_aabb_color")

	return Color.white

func get_tree_icon(highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon")

	return BrickHillResources.ICONS.tree_highlight_glue if highlight else BrickHillResources.ICONS.tree_glue

func _ready_group()->void :
	var scope = Profiler.scope(self, "_ready_group")

	pass

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Glue"] = {
		"":[
			"merge_collisions", 
		]
	}

	return categories
