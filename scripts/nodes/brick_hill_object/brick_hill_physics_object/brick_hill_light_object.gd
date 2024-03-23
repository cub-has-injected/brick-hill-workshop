class_name BrickHillLightObject
extends BrickHillPhysicsObject
tool 

enum ShadowMode{
	DUAL_PARABOLOID = OmniLight.SHADOW_DUAL_PARABOLOID, 
	CUBE = OmniLight.SHADOW_CUBE, 
}


export (Color) var light_color = Color.white setget set_light_color
export (float, 0, 16, 0.1) var light_energy = 0.0 setget set_light_energy
export (float, 0, 32, 0.1) var light_range = 8.0 setget set_light_range
export (Color) var shadow_color = Color.black setget set_shadow_color
export (ShadowMode) var shadow_mode = ShadowMode.DUAL_PARABOLOID setget set_shadow_mode


var omni_light:OmniLight = null


func set_light_color(new_light_color:Color)->void :
	var scope = Profiler.scope(self, "set_light_color", [new_light_color])

	if light_color != new_light_color:
		light_color = new_light_color
		if is_inside_tree():
			light_color_changed()

func set_shadow_color(new_shadow_color:Color)->void :
	var scope = Profiler.scope(self, "set_shadow_color", [new_shadow_color])

	if shadow_color != new_shadow_color:
		shadow_color = new_shadow_color
		if is_inside_tree():
			shadow_color_changed()

func set_shadow_mode(new_shadow_mode:int)->void :
	var scope = Profiler.scope(self, "set_shadow_mode", [new_shadow_mode])

	if shadow_mode != new_shadow_mode:
		shadow_mode = new_shadow_mode
		if is_inside_tree():
			shadow_mode_changed()

func set_light_energy(new_light_energy:float)->void :
	var scope = Profiler.scope(self, "set_light_energy", [new_light_energy])

	if light_energy != new_light_energy:
		light_energy = new_light_energy
		if is_inside_tree():
			light_energy_changed()

func set_light_range(new_light_range:float)->void :
	var scope = Profiler.scope(self, "set_light_range", [new_light_range])

	if light_range != new_light_range:
		light_range = new_light_range
		if is_inside_tree():
			light_range_changed()


func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "LightObject"


func object_mode_changed()->void :
	var scope = Profiler.scope(self, "object_mode_changed")

	.object_mode_changed()

func light_color_changed()->void :
	var scope = Profiler.scope(self, "light_color_changed")

	if omni_light:
		omni_light.light_color = light_color

func light_energy_changed()->void :
	var scope = Profiler.scope(self, "light_energy_changed")

	update_light()
	light_color_changed()
	light_range_changed()
	if omni_light:
		omni_light.light_energy = light_energy
		omni_light.light_indirect_energy = light_energy * 2

func light_range_changed()->void :
	var scope = Profiler.scope(self, "light_range_changed")

	if omni_light:
		omni_light.omni_range = light_range

func shadow_color_changed()->void :
	var scope = Profiler.scope(self, "shadow_color_changed")

	if omni_light:
		omni_light.shadow_color = shadow_color

func shadow_mode_changed()->void :
	var scope = Profiler.scope(self, "shadow_mode_changed")

	if omni_light:
		omni_light.omni_shadow_mode = shadow_mode


func update_light()->void :
	var scope = Profiler.scope(self, "update_light")

	for child in rigid_body.get_children():
		if child.has_meta("light_object_child"):
			rigid_body.remove_child(child)
			child.queue_free()

	omni_light = null

	if light_energy > 0:
		omni_light = OmniLight.new()
		omni_light.set_name("OmniLight")
		omni_light.shadow_enabled = true
		omni_light.omni_shadow_mode = shadow_mode
		omni_light.shadow_color = shadow_color

		omni_light.set_meta("light_object_child", true)
		rigid_body.add_child(omni_light)


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	._enter_tree()
	update_light()

	light_color_changed()
	light_energy_changed()
	light_range_changed()
	shadow_color_changed()
	shadow_mode_changed()

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Light"] = {
		"":[
			"light_color", 
			"light_energy", 
			"light_range", 
			"shadow_color", 
			"shadow_mode", 
		], 
	}

	return categories

func get_custom_property_names()->Dictionary:
	var custom_property_names = .get_custom_property_names()
	custom_property_names["light_color"] = "Color"
	custom_property_names["light_energy"] = "Energy"
	custom_property_names["light_range"] = "Range"
	custom_property_names["shadow_color"] = "Shadow Color"
	custom_property_names["shadow_mode"] = "Shadow Mode"
	return custom_property_names
