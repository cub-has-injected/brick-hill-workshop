class_name BrickHillMeshObject
extends BrickHillLightObject
tool 


export (Color) var albedo: = Color.white setget set_albedo
export (float) var roughness: = 0.25 setget set_roughness
export (float) var metallic: = 0.0 setget set_metallic
export (float) var refraction: = 0.0 setget set_refraction


var physics_interpolator:PhysicsInterpolator
var visual_mesh:MeshInstance
var shadow_mesh:MeshInstance

var shadow_mesh_material:SpatialMaterial

var material_data:BrickFaceMaterial setget set_material_data

var reflection_probe:ReflectionProbe = null


func set_material_data(new_material_data:BrickFaceMaterial)->void :
	var scope = Profiler.scope(self, "set_material_data", [new_material_data])

	if PRINT:
		print_debug("%s set material data to %s" % [get_name(), new_material_data.get_name()])

	if not new_material_data:
		new_material_data = preload("res://resources/brick_face_material/plastic.tres")

	if material_data != new_material_data:
		material_data = new_material_data
		if is_inside_tree():
			update_shader_params()

func set_albedo(new_albedo:Color)->void :
	var scope = Profiler.scope(self, "set_albedo", [new_albedo])

	if PRINT:
		print_debug("%s set albedo to %s" % [get_name(), new_albedo])

	if albedo != new_albedo:
		albedo = new_albedo
		if is_inside_tree():
			albedo_changed()

func set_roughness(new_roughness:float)->void :
	var scope = Profiler.scope(self, "set_roughness", [new_roughness])

	if PRINT:
		print_debug("%s set roughness to %s" % [get_name(), new_roughness])

	if roughness != new_roughness:
		roughness = new_roughness
		if is_inside_tree():
			roughness_changed()

func set_metallic(new_metallic:float)->void :
	var scope = Profiler.scope(self, "set_metallic", [new_metallic])

	if PRINT:
		print_debug("%s set metallic to %s" % [get_name(), new_metallic])

	if metallic != new_metallic:
		metallic = new_metallic
		if is_inside_tree():
			metallic_changed()

func set_refraction(new_refraction:float)->void :
	var scope = Profiler.scope(self, "set_refraction", [new_refraction])

	if PRINT:
		print_debug("%s set refraction to %s" % [get_name(), new_refraction])

	if refraction != new_refraction:
		refraction = new_refraction
		if is_inside_tree():
			refraction_changed()


func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Mesh"

func get_materials()->Array:
	var scope = Profiler.scope(self, "get_materials")

	if PRINT:
		print_debug("%s get materials" % [get_name()])

	return []

func get_bounds()->AABB:
	var scope = Profiler.scope(self, "get_bounds")

	var aabb = AABB()

	if visual_mesh:
		aabb = visual_mesh.get_aabb()

	return aabb


func object_mode_changed()->void :
	var scope = Profiler.scope(self, "object_mode_changed")

	.object_mode_changed()

	update_mesh_layers()
	update_mesh_baking()

func size_changed()->void :
	var scope = Profiler.scope(self, "size_changed")

	.size_changed()
	visual_mesh.scale = size
	shadow_mesh.scale = size

func albedo_changed()->void :
	var scope = Profiler.scope(self, "albedo_changed")

	update_shader_params()

func roughness_changed()->void :
	var scope = Profiler.scope(self, "roughness_changed")

	update_shader_params()

func metallic_changed()->void :
	var scope = Profiler.scope(self, "metallic_changed")

	update_shader_params()

func emission_color_changed():
	var scope = Profiler.scope(self, "emission_color_changed")

	.emission_color_changed()
	update_shadow_mesh_material()
	update_shader_params()

func emission_energy_changed():
	var scope = Profiler.scope(self, "emission_energy_changed")

	.emission_energy_changed()
	update_shadow_mesh_material()
	update_shader_params()

func refraction_changed()->void :
	var scope = Profiler.scope(self, "refraction_changed")

	update_shader_params()


func update_mesh():
	var scope = Profiler.scope(self, "update_mesh")

func update_mesh_layers()->void :
	var scope = Profiler.scope(self, "update_mesh_layers")

	var layers = 1 if object_mode == BrickHillUtil.ObjectMode.STATIC else 2
	visual_mesh.layers = layers
	shadow_mesh.layers = layers

func update_mesh_baking()->void :
	var scope = Profiler.scope(self, "update_mesh_baking")

	var is_static = object_mode == BrickHillUtil.ObjectMode.STATIC
	var not_light = light_energy == 0

	var bake = is_static and not_light
	visual_mesh.use_in_baked_light = bake
	shadow_mesh.use_in_baked_light = bake

	shadow_mesh.visible = not_light

func update_shadow_mesh_material()->void :
	var scope = Profiler.scope(self, "update_shadow_mesh_material")

	if shadow_mesh_material:
		shadow_mesh_material.emission = light_color * light_energy

func update_shader_params():
	var scope = Profiler.scope(self, "update_shader_params")

	if PRINT:
		print_debug("%s update shader params" % [get_name()])

	var materials = get_materials()
	
	for i in range(0, materials.size()):
		var material = materials[i]
		if not material:
			continue

		update_material(i, material)

func update_material(index:int, material:ShaderMaterial)->void :
	var scope = Profiler.scope(self, "update_material", [index, material])

	if PRINT:
		print_debug("%s update material %s, index %s" % [get_name(), material, index])

	if material_data:
		material.set_shader_param("texture_albedo", material_data.albedo_texture)
		material.set_shader_param("texture_normal", material_data.normal_texture)
		material.set_shader_param("texture_metallic", material_data.metallic_texture)
		material.set_shader_param("texture_roughness", material_data.roughness_texture)
		material.set_shader_param("texture_ambient_occlusion", material_data.ambient_occlusion_texture)
		material.set_shader_param("ao_light_affect", material_data.ambient_occlusion_light_affect)
	else :
		material.set_shader_param("texture_albedo", null)
		material.set_shader_param("texture_normal", null)
		material.set_shader_param("texture_metallic", null)
		material.set_shader_param("texture_roughness", null)
		material.set_shader_param("texture_ambient_occlusion", null)
		material.set_shader_param("ao_light_affect", 1.0)

	material.set_shader_param("albedo", albedo)
	material.set_shader_param("emission", light_color * light_energy)
	material.set_shader_param("roughness_scale", roughness)
	material.set_shader_param("metallic_scale", metallic)
	material.set_shader_param("refraction", refraction)


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	._enter_tree()

	for child in rigid_body.get_children():
		if child.has_meta("mesh_object_child"):
			rigid_body.remove_child(child)
			child.queue_free()

	physics_interpolator = PhysicsInterpolator.new()
	physics_interpolator.name = "PhysicsInterpolator"
	physics_interpolator.set_meta("mesh_object_child", true)
	rigid_body.add_child(physics_interpolator)


	visual_mesh = create_visual_mesh()
	visual_mesh.name = "VisualMesh"
	visual_mesh.cast_shadow = MeshInstance.SHADOW_CASTING_SETTING_OFF
	visual_mesh.set_meta("mesh_object_child", true)
	physics_interpolator.add_child(visual_mesh)

	shadow_mesh_material = SpatialMaterial.new()
	shadow_mesh_material.albedo_color = Color.black

	shadow_mesh = create_shadow_mesh()
	shadow_mesh.name = "ShadowMesh"
	shadow_mesh.cast_shadow = MeshInstance.SHADOW_CASTING_SETTING_SHADOWS_ONLY
	shadow_mesh.material_override = shadow_mesh_material
	shadow_mesh.set_meta("mesh_object_child", true)
	physics_interpolator.add_child(shadow_mesh)

	reflection_probe = null

func create_visual_mesh()->MeshInstance:
	var scope = Profiler.scope(self, "create_visual_mesh")

	return MeshInstance.new()

func create_shadow_mesh()->MeshInstance:
	var scope = Profiler.scope(self, "create_shadow_mesh")

	return MeshInstance.new()

func initial_update()->void :
	var scope = Profiler.scope(self, "initial_update")

	.initial_update()

	albedo_changed()
	roughness_changed()
	metallic_changed()

	update_mesh()
	update_shadow_mesh_material()
	update_shader_params()

func freeze()->void :
	var scope = Profiler.scope(self, "freeze")

	.freeze()
	physics_interpolator.active = false

func unfreeze()->void :
	var scope = Profiler.scope(self, "unfreeze")

	.unfreeze()
	physics_interpolator.active = not anchored

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Mesh"] = {
		"Appearance":[
			"albedo", 
			"material_data", 
			"roughness", 
			"metallic", 
			"refraction", 
			"reflection", 
		]
	}
	return categories

func get_custom_property_names()->Dictionary:
	var custom_property_names = .get_custom_property_names()
	return custom_property_names
