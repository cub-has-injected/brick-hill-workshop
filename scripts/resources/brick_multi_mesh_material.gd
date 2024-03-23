class_name BrickMultiMeshMaterial
extends ShaderMaterial
tool 

enum FeatureFlags{
	INSTANCED = 1, 
	PARALLAX_OCCLUSION_MAPPING = 2, 
	TRANSPARENT = 4, 
	TRANSLUCENT = 8, 
	REFRACTIVE = 16, 
	SINGLE_FACE = 32
}


var feature_flags:int setget set_feature_flags


var base_shader: = preload("res://resources/material/workshop/brick/brick_instanced.shader") as Shader setget set_base_shader
var albedo_texture_array:TextureArray
var normal_texture_array:TextureArray


func set_base_shader(new_base_shader:Shader)->void :
	var scope = Profiler.scope(self, "set_base_shader", [new_base_shader])

	if base_shader != new_base_shader:
		BrickHillUtil.disconnect_checked(base_shader, "changed", self, "update_shader")
		base_shader = new_base_shader
		BrickHillUtil.connect_checked(base_shader, "changed", self, "update_shader")
		update_shader()

func set_feature_flags(new_feature_flags:int)->void :
	var scope = Profiler.scope(self, "set_feature_flags", [new_feature_flags])

	if feature_flags != new_feature_flags:
		feature_flags = new_feature_flags
		update_shader()


func get_property_list_internal()->Array:
	var scope = Profiler.scope(self, "get_property_list_internal", [])

	return [
		{
			"name":"base_shader", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"Shader"
		}, 
		{
			"name":"feature_flags", 
			"type":TYPE_INT, 
			"hint":PROPERTY_HINT_FLAGS, 
			"hint_string":PropertyUtil.enum_to_hint_string(FeatureFlags)
		}
	]


func update_shader()->void :
	var scope = Profiler.scope(self, "update_shader", [])

	var tags: = PoolStringArray()

	for key in FeatureFlags:
		if FeatureFlags[key] & feature_flags == FeatureFlags[key]:
			tags.append(key)

	var base_lines = base_shader.code.split("\n")
	var shader_lines: = PoolStringArray()
	var skip_stack: = [false]

	for line in base_lines:
		var if_tag_pos = line.find("// IFDEF ")
		var ifnot_tag_pos = line.find("// IFNDEF ")
		var else_tag_pos = line.find("// ELSE")
		var endif_tag_pos = line.find("// ENDIF")

		if if_tag_pos != - 1:
			var tag = line.substr(if_tag_pos + 9, - 1)
			skip_stack.append( not tag in tags or skip_stack[ - 1])
		elif ifnot_tag_pos != - 1:
			var tag = line.substr(ifnot_tag_pos + 10, - 1)
			skip_stack.append(tag in tags or skip_stack[ - 1])
		elif else_tag_pos != - 1:
			if skip_stack.size() <= 1 or not skip_stack[ - 2]:
				skip_stack[ - 1] = not skip_stack[ - 1]
		elif endif_tag_pos != - 1:
			skip_stack.pop_back()
		elif not skip_stack[ - 1]:
			shader_lines.append(line)

	var parsed_shader: = Shader.new()
	parsed_shader.code = shader_lines.join("\n")

	shader = parsed_shader

	albedo_texture_array = TextureArray.new()
	normal_texture_array = TextureArray.new()

	write_texture_array(BrickHillResources.MATERIAL_ALBEDO_TEXTURES.values(), albedo_texture_array)
	write_texture_array(BrickHillResources.MATERIAL_NORMAL_TEXTURES.values(), normal_texture_array)

	set_shader_param("material_textures", albedo_texture_array)
	set_shader_param("normal_textures", normal_texture_array)
	set_shader_param("stud_normal", BrickHillResources.SURFACE_TEXTURES.normal)
	set_shader_param("stud_depth", BrickHillResources.SURFACE_TEXTURES.depth)


func _init(in_feature_flags:int = 0):
	var scope = Profiler.scope(self, "_init", [in_feature_flags])

	match GraphicsSettings.data.shader_pom_quality:
		0:
			in_feature_flags &= ~ FeatureFlags.PARALLAX_OCCLUSION_MAPPING
			set_shader_param("depth_min_layers", 1)
			set_shader_param("depth_max_layers", 1)
		1:
			in_feature_flags |= FeatureFlags.PARALLAX_OCCLUSION_MAPPING
			set_shader_param("depth_min_layers", 1)
			set_shader_param("depth_max_layers", 4)
		2:
			in_feature_flags |= FeatureFlags.PARALLAX_OCCLUSION_MAPPING
			set_shader_param("depth_min_layers", 4)
			set_shader_param("depth_max_layers", 8)
		3:
			in_feature_flags |= FeatureFlags.PARALLAX_OCCLUSION_MAPPING
			set_shader_param("depth_min_layers", 8)
			set_shader_param("depth_max_layers", 32)

	if GraphicsSettings.data.shader_translucency:
		in_feature_flags |= FeatureFlags.TRANSLUCENT
	else :
		in_feature_flags &= ~ FeatureFlags.TRANSLUCENT

	if GraphicsSettings.data.shader_refraction:
		in_feature_flags |= FeatureFlags.REFRACTIVE
	else :
		in_feature_flags &= ~ FeatureFlags.REFRACTIVE

	set_feature_flags(in_feature_flags)

	BrickHillUtil.connect_checked(GraphicsSettings.data, "shader_pom_quality_changed", self, "shader_pom_quality_changed")
	BrickHillUtil.connect_checked(GraphicsSettings.data, "shader_translucency_changed", self, "shader_translucency_changed")
	BrickHillUtil.connect_checked(GraphicsSettings.data, "shader_refraction_changed", self, "shader_refraction_changed")

func shader_pom_quality_changed()->void :
	var scope = Profiler.scope(self, "shader_pom_quality_changed", [])

	match GraphicsSettings.data.shader_pom_quality:
		0:
			set_feature_flags(feature_flags & ~ FeatureFlags.PARALLAX_OCCLUSION_MAPPING)
			set_shader_param("depth_min_layers", 1)
			set_shader_param("depth_max_layers", 1)
		1:
			set_feature_flags(feature_flags | FeatureFlags.PARALLAX_OCCLUSION_MAPPING)
			set_shader_param("depth_min_layers", 1)
			set_shader_param("depth_max_layers", 4)
		2:
			set_feature_flags(feature_flags | FeatureFlags.PARALLAX_OCCLUSION_MAPPING)
			set_shader_param("depth_min_layers", 4)
			set_shader_param("depth_max_layers", 8)
		3:
			set_feature_flags(feature_flags | FeatureFlags.PARALLAX_OCCLUSION_MAPPING)
			set_shader_param("depth_min_layers", 8)
			set_shader_param("depth_max_layers", 32)

func shader_translucency_changed()->void :
	var scope = Profiler.scope(self, "shader_translucency_changed", [])

	if GraphicsSettings.data.shader_translucency:
		set_feature_flags(feature_flags | FeatureFlags.TRANSLUCENT)
	else :
		set_feature_flags(feature_flags & ~ FeatureFlags.TRANSLUCENT)

func shader_refraction_changed()->void :
	var scope = Profiler.scope(self, "shader_refraction_changed", [])

	if GraphicsSettings.data.shader_refraction:
		set_feature_flags(feature_flags | FeatureFlags.REFRACTIVE)
	else :
		set_feature_flags(feature_flags & ~ FeatureFlags.REFRACTIVE)

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	return get_property_list_internal()


func write_texture_array(array:Array, texture_array:TextureArray)->void :
	var scope = Profiler.scope(self, "write_texture_array", [array, texture_array])

	if array.size() == 0:
		texture_array.create(1, 1, 1, Image.FORMAT_L8)
		return 

	var found_texture: = false
	var width:float
	var height:float
	var format:int

	for i in range(0, array.size()):
		if array[i]:
			width = array[i].get_width()
			height = array[i].get_height()
			format = array[i].get_data().get_format()
			found_texture = true
			break

	if not found_texture:
		return 

	texture_array.create(int(width), int(height), array.size(), format, Texture.FLAGS_DEFAULT | Texture.FLAG_ANISOTROPIC_FILTER)
	for i in range(0, array.size()):
		var texture: = array[i] as Texture
		if not texture:
			continue

		var image: = texture.get_data()
		texture_array.set_layer_data(image, i)
