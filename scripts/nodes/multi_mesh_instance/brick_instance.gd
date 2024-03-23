class_name BrickInstance
extends Spatial
tool 


const PRINT: = false


var mesh_type:int = ModelManager.BrickMeshType.CUBE setget set_mesh_type

var material_idx: = 0 setget set_material_idx

var albedo_palette: = PoolColorArray() setget set_albedo_palette
var emission_palette: = PoolColorArray() setget set_emission_palette
var surface_palette: = PoolByteArray() setget set_surface_palette
var opacity: = 1.0 setget set_opacity
var refraction: = 0.0 setget set_refraction

var roughness: = 0.7 setget set_roughness
var metallic: = 0.0 setget set_metallic

var uv_offset: = Vector2(0, 0) setget set_uv_offset

var use_in_baked_light: = true setget set_use_in_baked_light

var selected: = false setget set_selected
var hovered: = false setget set_hovered


var on_screen: = false
var prev_on_screen: = false
export (int) var palette_key: = - 1 setget set_palette_key


func set_mesh_type(new_mesh_type:int)->void :
	var scope = Profiler.scope(self, "set_mesh_type", [new_mesh_type])

	if mesh_type != new_mesh_type:
		if is_inside_tree():
			before_mesh_type_changed()

		mesh_type = new_mesh_type

		if is_inside_tree():
			after_mesh_type_changed()

func set_material_idx(new_material_idx:int)->void :
	var scope = Profiler.scope(self, "set_material_idx", [new_material_idx])

	if material_idx != new_material_idx:
		material_idx = new_material_idx
		if is_inside_tree():
			material_idx_changed()

func set_albedo_palette(new_albedo_palette:PoolColorArray)->void :
	var scope = Profiler.scope(self, "set_albedo_palette", [new_albedo_palette])

	if albedo_palette != new_albedo_palette:
		albedo_palette = new_albedo_palette
		if is_inside_tree():
			albedo_palette_changed()

func set_emission_palette(new_emission_palette:PoolColorArray)->void :
	var scope = Profiler.scope(self, "set_emission_palette", [new_emission_palette])

	if emission_palette != new_emission_palette:
		emission_palette = new_emission_palette
		if is_inside_tree():
			emission_palette_changed()

func set_surface_palette(new_surface_palette:PoolByteArray)->void :
	var scope = Profiler.scope(self, "set_surface_palette", [new_surface_palette])

	if surface_palette != new_surface_palette:
		surface_palette = new_surface_palette
		if is_inside_tree():
			surface_palette_changed()

func set_opacity(new_opacity:float)->void :
	var scope = Profiler.scope(self, "set_opacity", [new_opacity])

	if PRINT:
		print_debug("%s set opacity from %s to %s" % [get_name(), opacity, new_opacity])

	if opacity != new_opacity:
		var group_change = on_screen and ((opacity == 1.0 and new_opacity < 1.0) or (opacity < 1.0 and new_opacity == 1.0))
		if group_change:
			set_visible(false)

		opacity = new_opacity

		if group_change:
			set_visible(true)
		elif is_inside_tree():
			opacity_changed()

func set_refraction(new_refraction:float)->void :
	var scope = Profiler.scope(self, "set_refraction", [new_refraction])

	if refraction != new_refraction:
		refraction = new_refraction
		if is_inside_tree():
			refraction_changed()

func set_roughness(new_roughness:float)->void :
	var scope = Profiler.scope(self, "set_roughness", [new_roughness])

	if roughness != new_roughness:
		roughness = new_roughness
		if is_inside_tree():
			roughness_changed()

func set_metallic(new_metallic:float)->void :
	var scope = Profiler.scope(self, "set_metallic", [new_metallic])

	if metallic != new_metallic:
		metallic = new_metallic
		if is_inside_tree():
			metallic_changed()

func set_uv_offset(new_uv_offset:Vector2)->void :
	var scope = Profiler.scope(self, "set_uv_offset", [new_uv_offset])

	if uv_offset != new_uv_offset:
		uv_offset = new_uv_offset.round()
		if is_inside_tree():
			uv_offset_changed()

func set_use_in_baked_light(new_use_in_baked_light:bool)->void :
	var scope = Profiler.scope(self, "set_use_in_baked_light", [new_use_in_baked_light])

	if use_in_baked_light != new_use_in_baked_light:
		if is_inside_tree():
			before_use_in_baked_light_changed()

		use_in_baked_light = new_use_in_baked_light

		if is_inside_tree():
			after_use_in_baked_light_changed()

func set_selected(new_selected:bool)->void :
	var scope = Profiler.scope(self, "set_selected", [new_selected])

	if selected != new_selected:
		if is_inside_tree():
			before_selected_changed()

		selected = new_selected

		if is_inside_tree():
			after_selected_changed()

func set_hovered(new_hovered:bool)->void :
	var scope = Profiler.scope(self, "set_hovered", [new_hovered])

	if hovered != new_hovered:
		if is_inside_tree():
			before_hovered_changed()

		hovered = new_hovered

		if is_inside_tree():
			after_hovered_changed()

func set_palette_key(new_palette_key:int)->void :
	var scope = Profiler.scope(self, "set_palette_key", [new_palette_key])

	if PRINT:
		print_debug("%s %s set palette key from %s to %s" % [get_name(), self, palette_key, new_palette_key])
	if palette_key != new_palette_key:
		palette_key = new_palette_key
		if is_inside_tree():
			palette_key_changed()


func get_multi_mesh_manager():
	var scope = Profiler.scope(self, "get_multi_mesh_manager", [])

	return get_singleton_multi_mesh_manager()

func get_sibling_multi_mesh_manager():
	var scope = Profiler.scope(self, "get_sibling_multi_mesh_manager", [])

	return get_node("../MultiMeshManager") if has_node("../MultiMeshManager") else null

func get_set_root()->SetRoot:
	var scope = Profiler.scope(self, "get_set_root", [])

	var candidate = self
	while true:
		candidate = candidate.get_parent()
		if candidate is SetRoot or not candidate:
			break
	return candidate

func get_set_root_multi_mesh_manager():
	var scope = Profiler.scope(self, "get_set_root_multi_mesh_manager", [])

	var set_root = get_set_root()
	if not set_root:
		return null

	return set_root.get_node("MultiMeshManager") if set_root.has_node("MultiMeshManager") else null

func get_singleton_multi_mesh_manager():
	var scope = Profiler.scope(self, "get_singleton_multi_mesh_manager", [])

	return MultiMeshManager


func before_mesh_type_changed()->void :
	var scope = Profiler.scope(self, "before_mesh_type_changed", [])

	if on_screen:
		set_visible(false)

func after_mesh_type_changed()->void :
	var scope = Profiler.scope(self, "after_mesh_type_changed", [])

	if PRINT:
		print_debug("%s after mesh type changed" % [get_name()])

	if on_screen:
		set_visible(true)

func material_idx_changed()->void :
	var scope = Profiler.scope(self, "material_idx_changed", [])

	update_custom_data()

func palette_key_changed()->void :
	var scope = Profiler.scope(self, "palette_key_changed", [])

	update_custom_data()

func albedo_palette_changed()->void :
	var scope = Profiler.scope(self, "albedo_palette_changed", [])

	update_albedo_palette()

func emission_palette_changed()->void :
	var scope = Profiler.scope(self, "emission_palette_changed", [])

	update_emission_palette()

func surface_palette_changed()->void :
	var scope = Profiler.scope(self, "surface_palette_changed", [])

	update_surface_palette()

func opacity_changed()->void :
	var scope = Profiler.scope(self, "opacity_changed", [])

	update_color_data()

func refraction_changed()->void :
	var scope = Profiler.scope(self, "refraction_changed", [])

	update_color_data()

func roughness_changed()->void :
	var scope = Profiler.scope(self, "roughness_changed", [])

	update_color_data()

func metallic_changed()->void :
	var scope = Profiler.scope(self, "metallic_changed", [])

	update_color_data()

func uv_offset_changed()->void :
	var scope = Profiler.scope(self, "uv_offset_changed", [])

	update_custom_data()

func before_use_in_baked_light_changed()->void :
	var scope = Profiler.scope(self, "before_use_in_baked_light_changed", [])

	if on_screen:
		set_visible(false)

func after_use_in_baked_light_changed()->void :
	var scope = Profiler.scope(self, "after_use_in_baked_light_changed", [])

	if on_screen:
		set_visible(true)

func before_selected_changed()->void :
	var scope = Profiler.scope(self, "before_selected_changed", [])

func after_selected_changed()->void :
	var scope = Profiler.scope(self, "after_selected_changed", [])

	var category:String
	if use_in_baked_light:
		category = "static"
	else :
		category = "dynamic"

	if selected:
		MultiMeshManager.add_instance_to_category(self, category, "selected")
	else :
		MultiMeshManager.remove_instance_from_category(self, category, "selected")

func before_hovered_changed()->void :
	var scope = Profiler.scope(self, "before_hovered_changed", [])

func after_hovered_changed()->void :
	var scope = Profiler.scope(self, "after_hovered_changed", [])

	var category:String
	if use_in_baked_light:
		category = "static"
	else :
		category = "dynamic"

	if hovered:
		MultiMeshManager.add_instance_to_category(self, category, "hovered")
	else :
		MultiMeshManager.remove_instance_from_category(self, category, "hovered")

func on_screen_changed()->void :
	var scope = Profiler.scope(self, "on_screen_changed", [])

	if PRINT:
		print_debug("%s on screen changed: %s" % [get_name(), on_screen])

	if on_screen and not prev_on_screen:
		set_visible(true)
	elif not on_screen and prev_on_screen:
		set_visible(false)

	prev_on_screen = on_screen


func update_color_data()->void :
	var scope = Profiler.scope(self, "update_color_data", [])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.update_instance_color_data(self)

func update_custom_data()->void :
	var scope = Profiler.scope(self, "update_custom_data", [])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.update_instance_custom_data(self)

func update_albedo_palette()->void :
	var scope = Profiler.scope(self, "update_albedo_palette", [])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.update_instance_albedo_palette(self)

func update_emission_palette()->void :
	var scope = Profiler.scope(self, "update_emission_palette", [])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.update_instance_emission_palette(self)

func update_surface_palette()->void :
	var scope = Profiler.scope(self, "update_surface_palette", [])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.update_instance_surface_palette(self)

func update_visible()->void :
	var scope = Profiler.scope(self, "update_visible", [])

	set_visible(is_visible_in_tree())

func set_visible(new_visible:bool)->void :
	var scope = Profiler.scope(self, "set_visible", [new_visible])

	hide()

	if is_visible_in_tree() and new_visible:
		show()


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	set_notify_transform(true)

func visibility_culling_changed()->void :
	var scope = Profiler.scope(self, "visibility_culling_changed", [])

	on_screen = true
	prev_on_screen = on_screen
	set_visible(true)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	if PRINT:
		print_debug("%s %s enter tree" % [get_name(), self])
	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.register_instance(self)

	visibility_culling_changed()

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	if PRINT:
		print_debug("%s %s exit tree" % [get_name(), self])
	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.unregister_instance(self)

func _notification(what:int)->void :
	var scope = Profiler.scope(self, "_notification", [what])

	if what == NOTIFICATION_TRANSFORM_CHANGED:
		var multi_mesh_manager = get_multi_mesh_manager()
		if multi_mesh_manager:
			multi_mesh_manager.update_instance_transform(self)

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	return [
		{
			"name":"mesh_type", 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_ENUM, 
			"hint_string":PoolStringArray(ModelManager.BrickMeshType.keys()).join(",").capitalize()
		}, 
		{
			"name":"material_idx", 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_RANGE, 
			"hint_string":"0,6,1"
		}, 
		{
			"name":"albedo_palette", 
			"type":TYPE_COLOR_ARRAY
		}, 
		{
			"name":"emission_palette", 
			"type":TYPE_COLOR_ARRAY
		}, 
		{
			"name":"surface_palette", 
			"type":TYPE_ARRAY, 
			"hint":PropertyUtil.PROPERTY_HINT_TYPE_STRING, 
			"hint_string":PropertyUtil.flags_array_hint_string(["Studded", "Alternating", "Flip", "Bevel"])
		}, 
		{
			"name":"opacity", 
			"type":TYPE_REAL, 
			"hint":PROPERTY_HINT_RANGE, 
			"hint_string":"0,1,0.01"
		}, 
		{
			"name":"refraction", 
			"type":TYPE_REAL, 
			"hint":PROPERTY_HINT_RANGE, 
			"hint_string":"0,1,0.01"
		}, 
		{
			"name":"roughness", 
			"type":TYPE_REAL, 
			"hint":PROPERTY_HINT_RANGE, 
			"hint_string":"0,1,0.01"
		}, 
		{
			"name":"metallic", 
			"type":TYPE_REAL, 
			"hint":PROPERTY_HINT_RANGE, 
			"hint_string":"0,1,0.01"
		}, 
		{
			"name":"use_in_baked_light", 
			"type":TYPE_BOOL
		}, 
		{
			"name":"selected", 
			"type":TYPE_BOOL
		}, 
		{
			"name":"hovered", 
			"type":TYPE_BOOL
		}
	]


func show()->void :
	var scope = Profiler.scope(self, "show", [])

	if PRINT:
		print_debug("%s %s show" % [get_name(), self])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.show_instance(self)

func hide()->void :
	var scope = Profiler.scope(self, "hide", [])

	if PRINT:
		print_debug("%s %s hide" % [get_name(), self])

	var multi_mesh_manager = get_multi_mesh_manager()
	if multi_mesh_manager:
		multi_mesh_manager.hide_instance(self)
