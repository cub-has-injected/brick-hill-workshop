extends Spatial
tool 

const MAX_FACES: = 7
const MAX_BRICKS: = 10240

export (bool) var debug_print: = false
export (bool) var debug_draw: = false

var category_materials: = {
	"static":{
		"opaque":BrickMultiMeshMaterial.new(
			BrickMultiMeshMaterial.FeatureFlags.INSTANCED
		), 
		"transparent":BrickMultiMeshMaterial.new(
			BrickMultiMeshMaterial.FeatureFlags.INSTANCED | 
			BrickMultiMeshMaterial.FeatureFlags.TRANSPARENT
		), 
		"shadow":null, 
		"selected":null, 
		"hovered":null, 
	}, 
	"dynamic":{
		"opaque":BrickMultiMeshMaterial.new(
			BrickMultiMeshMaterial.FeatureFlags.INSTANCED
		), 
		"transparent":BrickMultiMeshMaterial.new(
			BrickMultiMeshMaterial.FeatureFlags.INSTANCED | 
			BrickMultiMeshMaterial.FeatureFlags.TRANSPARENT
		), 
		"shadow":null, 
		"selected":null, 
		"hovered":null, 
	}
}

var multi_mesh_instances:Dictionary

var instances:Dictionary
var instance_albedo_palettes:Dictionary
var instance_emission_palettes:Dictionary
var instance_surface_palettes:Dictionary

var albedo_palette_image:Image
var albedo_palette_texture:ImageTexture
var albedo_palette_texture_rect:TextureRect

var emission_palette_image:Image
var emission_palette_texture:ImageTexture
var emission_palette_texture_rect:TextureRect

var surface_palette_image:Image
var surface_palette_texture:ImageTexture
var surface_palette_texture_rect:TextureRect

var canvas_layer:CanvasLayer
var texture_rect_hbox:HBoxContainer

export (bool) var _init: = false setget set_init

func set_init(_new_init:bool)->void :
	var scope = Profiler.scope(self, "set_init", [_new_init])

	if not _init and is_inside_tree():
		initialize()

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	initialize()

func initialize()->void :
	var scope = Profiler.scope(self, "initialize", [])

	albedo_palette_image = Image.new()
	albedo_palette_texture = ImageTexture.new()
	emission_palette_image = Image.new()
	emission_palette_texture = ImageTexture.new()
	surface_palette_image = Image.new()
	surface_palette_texture = ImageTexture.new()

	if not Engine.is_editor_hint() and debug_draw:
		canvas_layer = CanvasLayer.new()

		texture_rect_hbox = HBoxContainer.new()
		texture_rect_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

		albedo_palette_texture_rect = TextureRect.new()
		albedo_palette_texture_rect.texture = albedo_palette_texture
		albedo_palette_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		emission_palette_texture_rect = TextureRect.new()
		emission_palette_texture_rect.texture = emission_palette_texture
		emission_palette_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		surface_palette_texture_rect = TextureRect.new()
		surface_palette_texture_rect.texture = surface_palette_texture
		surface_palette_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		texture_rect_hbox.add_child(albedo_palette_texture_rect)
		texture_rect_hbox.add_child(emission_palette_texture_rect)
		texture_rect_hbox.add_child(surface_palette_texture_rect)

		canvas_layer.add_child(texture_rect_hbox)

		add_child(canvas_layer)

	multi_mesh_instances = {}
	instances = {}
	instance_albedo_palettes = {}
	instance_emission_palettes = {}
	instance_surface_palettes = {}

	
	albedo_palette_image.create(MAX_FACES, MAX_BRICKS, false, Image.FORMAT_RGB8)
	albedo_palette_image.fill(Color.white)

	albedo_palette_texture.create_from_image(albedo_palette_image, Texture.FLAG_VIDEO_SURFACE)
	albedo_palette_texture.set_data(albedo_palette_image)

	
	emission_palette_image.create(MAX_FACES, MAX_BRICKS, false, Image.FORMAT_RGBF)
	emission_palette_image.fill(Color.black)

	emission_palette_texture.create_from_image(emission_palette_image, Texture.FLAG_VIDEO_SURFACE)
	emission_palette_texture.set_data(emission_palette_image)

	
	surface_palette_image.create(MAX_FACES, MAX_BRICKS, false, Image.FORMAT_RGBF)
	surface_palette_image.fill(Color.black)

	surface_palette_texture.create_from_image(surface_palette_image, Texture.FLAG_VIDEO_SURFACE)
	surface_palette_texture.set_data(surface_palette_image)

	
	for child in get_children():
		if child.has_meta("multi_mesh_manager_child"):
			remove_child(child)
			child.queue_free()

	for category in category_materials:
		create_multi_mesh_category(category)

	BrickHillUtil.connect_checked(get_tree(), "idle_frame", self, "flush_write_queues")

	_init = true

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	BrickHillUtil.disconnect_checked(get_tree(), "idle_frame", self, "flush_write_queues")

var albedo_write_queue: = []
func queue_albedo_write(x:int, y:int, color:Color)->void :
	var scope = Profiler.scope(self, "queue_albedo_write", [x, y, color])

	assert (x >= 0)
	assert (y >= 0)
	albedo_write_queue.append([x, y, color])

var emission_write_queue: = []
func queue_emission_write(x:int, y:int, color:Color)->void :
	var scope = Profiler.scope(self, "queue_emission_write", [x, y, color])

	assert (x >= 0)
	assert (y >= 0)
	emission_write_queue.append([x, y, color])

var surface_write_queue: = []
func queue_surface_write(x:int, y:int, color:Color)->void :
	var scope = Profiler.scope(self, "queue_surface_write", [x, y, color])

	assert (x >= 0)
	assert (y >= 0)
	surface_write_queue.append([x, y, color])

func flush_write_queues()->void :
	var scope = Profiler.scope(self, "flush_write_queues", [])

	albedo_palette_image.lock()
	for albedo_write in albedo_write_queue:
		albedo_palette_image.set_pixel(
			albedo_write[0], 
			albedo_write[1], 
			albedo_write[2]
		)
	albedo_write_queue.clear()
	albedo_palette_image.unlock()
	albedo_palette_texture.set_data(albedo_palette_image)

	emission_palette_image.lock()
	for emission_write in emission_write_queue:
		emission_palette_image.set_pixel(
			emission_write[0], 
			emission_write[1], 
			emission_write[2]
		)
	emission_write_queue.clear()
	emission_palette_image.unlock()
	emission_palette_texture.set_data(emission_palette_image)

	surface_palette_image.lock()
	for surface_write in surface_write_queue:
		surface_palette_image.set_pixel(
			surface_write[0], 
			surface_write[1], 
			surface_write[2]
		)
	surface_write_queue.clear()
	surface_palette_image.unlock()
	surface_palette_texture.set_data(surface_palette_image)

func get_bounds()->AABB:
	var scope = Profiler.scope(self, "get_bounds", [])

	var aabb: = AABB()
	for key in instances:
		var instance = instances[key]
		if instance:
			aabb = aabb.merge(instance.global_transform.xform(instance.aabb))
	return aabb

func create_multi_mesh_category(category:String)->void :
	var scope = Profiler.scope(self, "create_multi_mesh_category", [category])

	if debug_print:
		print("create multi mesh category %s" % [category])

	var category_node = Spatial.new()
	category_node.name = category.capitalize()
	category_node.set_meta("multi_mesh_manager_child", true)
	add_child(category_node)

	for subcategory in category_materials[category]:
		var material = category_materials[category][subcategory]
		if material:
			material.set_shader_param("albedo_palette", albedo_palette_texture)
			material.set_shader_param("emission_palette", emission_palette_texture)
			material.set_shader_param("surface_palette", surface_palette_texture)
		create_multi_mesh_subcategory(category, subcategory, category_node, material)

func create_multi_mesh_subcategory(category:String, subcategory:String, category_node:Spatial, material:ShaderMaterial)->void :
	var scope = Profiler.scope(self, "create_multi_mesh_subcategory", [category, subcategory, category_node, material])

	if debug_print:
		print("create multi mesh subcategory %s, %s, %s, %s" % [category, subcategory, category_node, material])

	var subcategory_node = Spatial.new()
	subcategory_node.name = subcategory.capitalize()
	category_node.add_child(subcategory_node)

	for key in ModelManager.BrickMeshType.keys():
		var mesh_type = ModelManager.BrickMeshType[key]
		var brick_multi_mesh = BrickMultiMeshInstance.new()
		brick_multi_mesh.mesh_type = mesh_type
		brick_multi_mesh.name = key.capitalize()
		brick_multi_mesh.material_override = material

		if category == "static":
			brick_multi_mesh.use_in_baked_light = true

		if subcategory == "shadow":
			brick_multi_mesh.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		else :
			brick_multi_mesh.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF

		if subcategory == "selected":
			brick_multi_mesh.layers = 2
		elif subcategory == "hovered":
			brick_multi_mesh.layers = 4
		else :
			brick_multi_mesh.layers = 1

		subcategory_node.add_child(brick_multi_mesh)
		set_multi_mesh_instance_for_type(category, subcategory, mesh_type, brick_multi_mesh)

func get_multi_mesh_instances_for_instance(instance)->Array:
	var scope = Profiler.scope(self, "get_multi_mesh_instances_for_instance", [instance])

	if debug_print:
		print("%s get multi mesh instances for instance: %s" % [get_name(), instance])

	var category = "dynamic"
	if instance.use_in_baked_light:
		category = "static"

	var subcategories = ["opaque", "shadow"]
	if instance.opacity < 1.0:
		subcategories = ["transparent", "shadow"]

	if instance.selected:
		subcategories += ["selected"]

	if instance.hovered:
		subcategories += ["hovered"]

	var mesh_instances: = []
	for subcategory in subcategories:
		mesh_instances.append(get_multi_mesh_instance_for_type(category, subcategory, instance.mesh_type))

	return mesh_instances

func get_multi_mesh_instance_for_type(category:String, subcategory:String, mesh_type:int)->MultiMeshInstance:
	var scope = Profiler.scope(self, "get_multi_mesh_instance_for_type", [category, subcategory, mesh_type])

	if debug_print:
		print("%s get multi mesh instance for type: %s %s %s" % [get_name(), category, subcategory, mesh_type])

	if not category in multi_mesh_instances:
		return null

	if not subcategory in multi_mesh_instances[category]:
		return null

	if not mesh_type in multi_mesh_instances[category][subcategory]:
		return null

	return multi_mesh_instances[category][subcategory][mesh_type]

func set_multi_mesh_instance_for_type(category:String, subcategory:String, mesh_type:int, multi_mesh_instance:MultiMeshInstance)->void :
	var scope = Profiler.scope(self, "set_multi_mesh_instance_for_type", [category, subcategory, mesh_type, multi_mesh_instance])

	if debug_print:
		print("%s set multi mesh instance for type: %s %s %s %s" % [get_name(), category, subcategory, mesh_type, multi_mesh_instance])

	if not category in multi_mesh_instances:
		multi_mesh_instances[category] = {}

	if not subcategory in multi_mesh_instances[category]:
		multi_mesh_instances[category][subcategory] = {}

	multi_mesh_instances[category][subcategory][mesh_type] = multi_mesh_instance

var instance_idx: = 0
func register_instance(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "register_instance", [instance])

	if debug_print:
		print("%s register instance: %s" % [get_name(), instance])

	if instance:
		instance_idx += 1
		if instance_idx >= MAX_BRICKS:
			instance_idx = 0
		instance.palette_key = instance_idx
		instances[instance_idx] = instance
		instance_albedo_palettes[instance.palette_key] = PoolColorArray()
		instance_emission_palettes[instance.palette_key] = PoolColorArray()
		instance_surface_palettes[instance.palette_key] = PoolRealArray()

		update_instance_albedo_palette(instance)
		update_instance_emission_palette(instance)
		update_instance_surface_palette(instance)

func unregister_instance(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "unregister_instance", [instance])

	if debug_print:
		print("%s unregister instance: %s" % [get_name(), instance])

	hide_instance(instance)

	instances.erase(instance.palette_key)
	instance_albedo_palettes.erase(instance.palette_key)
	instance_emission_palettes.erase(instance.palette_key)
	instance_surface_palettes.erase(instance.palette_key)

func show_instance(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "show_instance", [instance])

	if debug_print:
		print("%s show instance: %s" % [get_name(), instance])

	if instance:
		var multi_meshes = get_multi_mesh_instances_for_instance(instance)
		for multi_mesh in multi_meshes:
			multi_mesh.add_instance(instance)

func hide_instance(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "hide_instance", [instance])

	if debug_print:
		print("%s hide instance: %s" % [get_name(), instance])

	if instance:
		var multi_meshes = get_multi_mesh_instances_for_instance(instance)
		for multi_mesh in multi_meshes:
			multi_mesh.remove_instance(instance)
		remove_instance_from_category(instance, "dynamic", "hovered")
		remove_instance_from_category(instance, "dynamic", "selected")

func update_instance_transform(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance_transform", [instance])

	if debug_print:
		print("%s update instance transform: %s" % [get_name(), instance])

	if instance:
		var multi_meshes = get_multi_mesh_instances_for_instance(instance)
		for multi_mesh in multi_meshes:
			if multi_mesh:
				var idx = multi_mesh.get_multi_mesh_index(instance)
				var multi_mesh_instance = multi_mesh.get_instance_by_idx(idx)
				multi_mesh.update_instance_transform(idx, multi_mesh_instance)

func update_instance_color_data(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance_color_data", [instance])

	if debug_print:
		print("%s update instance color data: %s" % [get_name(), instance])

	if instance:
		var multi_meshes = get_multi_mesh_instances_for_instance(instance)
		for multi_mesh in multi_meshes:
			if multi_mesh:
				var idx = multi_mesh.get_multi_mesh_index(instance)
				var multi_mesh_instance = multi_mesh.get_instance_by_idx(idx)
				multi_mesh.update_instance_color_data(idx, multi_mesh_instance)

func update_instance_custom_data(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance_custom_data", [instance])

	if debug_print:
		print("%s update instance custom data: %s" % [get_name(), instance])

	if instance:
		var multi_meshes = get_multi_mesh_instances_for_instance(instance)
		for multi_mesh in multi_meshes:
			if multi_mesh:
				var idx = multi_mesh.get_multi_mesh_index(instance)
				var multi_mesh_instance = multi_mesh.get_instance_by_idx(idx)
				multi_mesh.update_instance_custom_data(idx, multi_mesh_instance)

func update_instance_albedo_palette(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance_albedo_palette", [instance])

	if debug_print:
		print("%s update instance albedo palette: %s" % [get_name(), instance])

	instance_albedo_palettes[instance.palette_key] = instance.albedo_palette

	for i in range(0, MAX_FACES):
		if i < instance.albedo_palette.size():
			queue_albedo_write(i, instance.palette_key, instance.albedo_palette[i])
		else :
			queue_albedo_write(i, instance.palette_key, Color.white)

func update_instance_emission_palette(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance_emission_palette", [instance])

	if debug_print:
		print("%s update instance emission palette: %s" % [get_name(), instance])

	instance_emission_palettes[instance.palette_key] = instance.emission_palette

	for i in range(0, MAX_FACES):
		if i < instance.emission_palette.size():
			queue_emission_write(i, instance.palette_key, instance.emission_palette[i])
		else :
			queue_emission_write(i, instance.palette_key, Color.black)

func update_instance_surface_palette(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance_surface_palette", [instance])

	if debug_print:
		print("%s update instance surface palette: %s" % [get_name(), instance])

	instance_surface_palettes[instance.palette_key] = instance.surface_palette

	for i in range(0, MAX_FACES):
		if i < instance.surface_palette.size():
			queue_surface_write(i, instance.palette_key, Color(instance.surface_palette[i], 0.0, 0.0, 1.0))
		else :
			queue_surface_write(i, instance.palette_key, Color.black)


func add_instance_to_category(instance:BrickInstance, category:String, subcategory:String)->void :
	var multi_mesh = get_multi_mesh_instance_for_type(category, subcategory, instance.mesh_type)
	multi_mesh.add_instance(instance)

func remove_instance_from_category(instance:BrickInstance, category:String, subcategory:String)->void :
	var multi_mesh = get_multi_mesh_instance_for_type(category, subcategory, instance.mesh_type)
	multi_mesh.remove_instance(instance)
