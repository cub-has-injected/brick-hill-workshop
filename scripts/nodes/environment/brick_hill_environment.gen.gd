class_name BrickHillEnvironmentGen
extends Spatial
tool 


export (float) var gravity_strength: = 1.0 setget set_gravity_strength
export (Vector3) var gravity_direction: = Vector3(0, - 1, 0) setget set_gravity_direction

export (int) var skybox_asset_id:int = 416649 setget set_skybox_asset_id

export (bool) var sun_enabled: = true setget set_sun_enabled
export (float, - 90, 270, 1) var sun_latitude: = 35.0 setget set_sun_latitude
export (float, - 180, 180, 1) var sun_longitude: = 180.0 setget set_sun_longitude
export (Color) var sun_inner_color: = Color.white setget set_sun_inner_color
export (Color) var sun_outer_color: = Color.white setget set_sun_outer_color
export (Color) var sun_shadow_color: = Color.black setget set_sun_shadow_color
export (bool) var sun_horizon_cutoff: = true setget set_sun_horizon_cutoff

export (float, 0, 1, 0.01) var sky_energy: = 1.0 setget set_sky_energy
export (Color) var sky_color: = Color("#a5d6f1") setget set_sky_color
export (float, 0, 1, 0.01) var sky_curve: = 0.09 setget set_sky_curve

export (Color) var horizon_upper_color: = Color("#d6eafa") setget set_horizon_upper_color
export (Color) var horizon_lower_color: = Color("#6c655f") setget set_horizon_lower_color

export (Color) var ground_color: = Color("#282f36") setget set_ground_color
export (float, 0, 1, 0.01) var ground_curve: = 0.09 setget set_ground_curve

export (Color) var ambient_light_color: = Color("#d8d8d8") setget set_ambient_light_color
export (float, 0, 1, 0.01) var ambient_light_energy: = 1.0 setget set_ambient_light_energy
export (float, 0, 1, 0.01) var ambient_light_sky_contribution: = 0.0 setget set_ambient_light_sky_contribution

export (bool) var fog_enabled: = false setget set_fog_enabled
export (Color) var fog_color: = Color(0.501961, 0.6, 0.701961, 1) setget set_fog_color
export (float, 0, 1, 0.01) var fog_intensity: = 1.0 setget set_fog_intensity
export (float, 0, 1, 0.01) var fog_sun_amount: = 0.0 setget set_fog_sun_amount

export (bool) var fog_depth_enabled: = true setget set_fog_depth_enabled
export (float, 0, 1000, 0.5) var fog_depth_begin: = 20.0 setget set_fog_depth_begin
export (float, 0, 1000, 0.5) var fog_depth_end: = 50.0 setget set_fog_depth_end

export (bool) var fog_height_enabled: = true setget set_fog_height_enabled
export (float, - 1000, 1000, 0.5) var fog_height_min: = 4.0 setget set_fog_height_min
export (float, - 1000, 1000, 0.5) var fog_height_max: = - 2.0 setget set_fog_height_max


var environment:Environment

var procedural_sky:ProceduralSky
var panorama_sky:PanoramaSky
var sun_mesh_instance:MeshInstance
var sun_mesh:QuadMesh
var sun_material:ShaderMaterial


func set_gravity_strength(new_gravity_strength)->void :
	var scope = Profiler.scope(self, "set_gravity_strength", [new_gravity_strength])

	if gravity_strength != new_gravity_strength:
		gravity_strength = new_gravity_strength
		if is_inside_tree():
			update_gravity()

func set_gravity_direction(new_gravity_direction)->void :
	var scope = Profiler.scope(self, "set_gravity_direction", [new_gravity_direction])

	if gravity_direction != new_gravity_direction:
		gravity_direction = new_gravity_direction
		if is_inside_tree():
			update_gravity()

func set_skybox_asset_id(new_skybox_asset_id)->void :
	var scope = Profiler.scope(self, "set_skybox_asset_id", [new_skybox_asset_id])

	if skybox_asset_id != new_skybox_asset_id:
		skybox_asset_id = new_skybox_asset_id
		if is_inside_tree():
			update_sky()

func set_sun_enabled(new_sun_enabled)->void :
	var scope = Profiler.scope(self, "set_sun_enabled", [new_sun_enabled])

	if sun_enabled != new_sun_enabled:
		sun_enabled = new_sun_enabled
		if is_inside_tree():
			update_sky()

func set_sun_shadow_color(new_sun_shadow_color)->void :
	var scope = Profiler.scope(self, "set_sun_shadow_color", [new_sun_shadow_color])

	if sun_shadow_color != new_sun_shadow_color:
		sun_shadow_color = new_sun_shadow_color
		if is_inside_tree():
			update_sky()

func set_sun_horizon_cutoff(new_sun_horizon_cutoff)->void :
	var scope = Profiler.scope(self, "set_sun_horizon_cutoff", [new_sun_horizon_cutoff])

	if sun_horizon_cutoff != new_sun_horizon_cutoff:
		sun_horizon_cutoff = new_sun_horizon_cutoff
		if is_inside_tree():
			update_sky()

func set_sun_latitude(new_sun_latitude)->void :
	var scope = Profiler.scope(self, "set_sun_latitude", [new_sun_latitude])

	if sun_latitude != new_sun_latitude:
		sun_latitude = new_sun_latitude
		if is_inside_tree():
			update_sky()

func set_sun_longitude(new_sun_longitude)->void :
	var scope = Profiler.scope(self, "set_sun_longitude", [new_sun_longitude])

	if sun_longitude != new_sun_longitude:
		sun_longitude = new_sun_longitude
		if is_inside_tree():
			update_sky()

func set_sun_inner_color(new_sun_inner_color)->void :
	var scope = Profiler.scope(self, "set_sun_inner_color", [new_sun_inner_color])

	if sun_inner_color != new_sun_inner_color:
		sun_inner_color = new_sun_inner_color
		if is_inside_tree():
			update_sky()

func set_sun_outer_color(new_sun_outer_color)->void :
	var scope = Profiler.scope(self, "set_sun_outer_color", [new_sun_outer_color])

	if sun_outer_color != new_sun_outer_color:
		sun_outer_color = new_sun_outer_color
		if is_inside_tree():
			update_sky()

func set_sky_energy(new_sky_energy)->void :
	var scope = Profiler.scope(self, "set_sky_energy", [new_sky_energy])

	if sky_energy != new_sky_energy:
		sky_energy = new_sky_energy
		if is_inside_tree():
			update_sky()

func set_sky_color(new_sky_color)->void :
	var scope = Profiler.scope(self, "set_sky_color", [new_sky_color])

	if sky_color != new_sky_color:
		sky_color = new_sky_color
		if is_inside_tree():
			update_sky()

func set_sky_curve(new_sky_curve)->void :
	var scope = Profiler.scope(self, "set_sky_curve", [new_sky_curve])

	if sky_curve != new_sky_curve:
		sky_curve = new_sky_curve
		if is_inside_tree():
			update_sky()

func set_horizon_upper_color(new_horizon_upper_color)->void :
	var scope = Profiler.scope(self, "set_horizon_upper_color", [new_horizon_upper_color])

	if horizon_upper_color != new_horizon_upper_color:
		horizon_upper_color = new_horizon_upper_color
		if is_inside_tree():
			update_sky()

func set_horizon_lower_color(new_horizon_lower_color)->void :
	var scope = Profiler.scope(self, "set_horizon_lower_color", [new_horizon_lower_color])

	if horizon_lower_color != new_horizon_lower_color:
		horizon_lower_color = new_horizon_lower_color
		if is_inside_tree():
			update_sky()

func set_ground_color(new_ground_color)->void :
	var scope = Profiler.scope(self, "set_ground_color", [new_ground_color])

	if ground_color != new_ground_color:
		ground_color = new_ground_color
		if is_inside_tree():
			update_sky()

func set_ground_curve(new_ground_curve)->void :
	var scope = Profiler.scope(self, "set_ground_curve", [new_ground_curve])

	if ground_curve != new_ground_curve:
		ground_curve = new_ground_curve
		if is_inside_tree():
			update_sky()

func set_ambient_light_color(new_ambient_light_color)->void :
	var scope = Profiler.scope(self, "set_ambient_light_color", [new_ambient_light_color])

	if ambient_light_color != new_ambient_light_color:
		ambient_light_color = new_ambient_light_color
		if is_inside_tree():
			update_ambient_light()

func set_ambient_light_energy(new_ambient_light_energy)->void :
	var scope = Profiler.scope(self, "set_ambient_light_energy", [new_ambient_light_energy])

	if ambient_light_energy != new_ambient_light_energy:
		ambient_light_energy = new_ambient_light_energy
		if is_inside_tree():
			update_ambient_light()

func set_ambient_light_sky_contribution(new_ambient_light_sky_contribution)->void :
	var scope = Profiler.scope(self, "set_ambient_light_sky_contribution", [new_ambient_light_sky_contribution])

	if ambient_light_sky_contribution != new_ambient_light_sky_contribution:
		ambient_light_sky_contribution = new_ambient_light_sky_contribution
		if is_inside_tree():
			update_ambient_light()

func set_fog_enabled(new_fog_enabled)->void :
	var scope = Profiler.scope(self, "set_fog_enabled", [new_fog_enabled])

	if fog_enabled != new_fog_enabled:
		fog_enabled = new_fog_enabled
		if is_inside_tree():
			update_fog()

func set_fog_color(new_fog_color)->void :
	var scope = Profiler.scope(self, "set_fog_color", [new_fog_color])

	if fog_color != new_fog_color:
		fog_color = new_fog_color
		if is_inside_tree():
			update_fog()

func set_fog_intensity(new_fog_intensity)->void :
	var scope = Profiler.scope(self, "set_fog_intensity", [new_fog_intensity])

	if fog_intensity != new_fog_intensity:
		fog_intensity = new_fog_intensity
		if is_inside_tree():
			update_fog()

func set_fog_sun_amount(new_fog_sun_amount:float)->void :
	var scope = Profiler.scope(self, "set_fog_sun_amount", [new_fog_sun_amount])

	if fog_sun_amount != new_fog_sun_amount:
		fog_sun_amount = new_fog_sun_amount
		if is_inside_tree():
			update_fog()

func set_fog_depth_enabled(new_fog_depth_enabled)->void :
	var scope = Profiler.scope(self, "set_fog_depth_enabled", [new_fog_depth_enabled])

	if fog_depth_enabled != new_fog_depth_enabled:
		fog_depth_enabled = new_fog_depth_enabled
		if is_inside_tree():
			update_fog()

func set_fog_depth_begin(new_fog_depth_begin)->void :
	var scope = Profiler.scope(self, "set_fog_depth_begin", [new_fog_depth_begin])

	if fog_depth_begin != new_fog_depth_begin:
		fog_depth_begin = new_fog_depth_begin
		if is_inside_tree():
			update_fog()

func set_fog_depth_end(new_fog_depth_end)->void :
	var scope = Profiler.scope(self, "set_fog_depth_end", [new_fog_depth_end])

	if fog_depth_end != new_fog_depth_end:
		fog_depth_end = new_fog_depth_end
		if is_inside_tree():
			update_fog()

func set_fog_height_enabled(new_fog_height_enabled)->void :
	var scope = Profiler.scope(self, "set_fog_height_enabled", [new_fog_height_enabled])

	if fog_height_enabled != new_fog_height_enabled:
		fog_height_enabled = new_fog_height_enabled
		if is_inside_tree():
			update_fog()

func set_fog_height_min(new_fog_height_min)->void :
	var scope = Profiler.scope(self, "set_fog_height_min", [new_fog_height_min])

	if fog_height_min != new_fog_height_min:
		fog_height_min = new_fog_height_min
		if is_inside_tree():
			update_fog()

func set_fog_height_max(new_fog_height_max)->void :
	var scope = Profiler.scope(self, "set_fog_height_max", [new_fog_height_max])

	if fog_height_max != new_fog_height_max:
		fog_height_max = new_fog_height_max
		if is_inside_tree():
			update_fog()


func update_gravity()->void :
	var scope = Profiler.scope(self, "update_gravity", [])

	var viewport = get_viewport()
	var world = viewport.find_world()
	var space = world.get_space()
	PhysicsServer.area_set_param(space, PhysicsServer.AREA_PARAM_GRAVITY, gravity_strength * 9.8)
	PhysicsServer.area_set_param(space, PhysicsServer.AREA_PARAM_GRAVITY_VECTOR, gravity_direction.normalized())


func update_sky()->void :
	var scope = Profiler.scope(self, "update_sky", [])

	if skybox_asset_id != - 1:
#		var asset = yield (BrickHillAssets.get_asset(String(skybox_asset_id)), "completed")
#		panorama_sky.panorama = asset.panorama_texture
		var sko = PanoramaSky.new()
		sko.panorama = preload("res://resources/texture/environment/procedural_sky_icon.png")
		environment.background_sky = sko
	else :
		procedural_sky.sky_energy = sky_energy
		procedural_sky.sky_top_color = sky_color
		procedural_sky.sky_horizon_color = horizon_upper_color
		procedural_sky.sky_curve = sky_curve

		procedural_sky.ground_horizon_color = horizon_lower_color
		procedural_sky.ground_bottom_color = ground_color
		procedural_sky.ground_curve = ground_curve

		procedural_sky.sun_latitude = - 90
		procedural_sky.sun_longitude = 0

		environment.background_sky = procedural_sky

	sun_mesh_instance.visible = sun_enabled

	sun_material.set_shader_param("inner_color", sun_inner_color)
	sun_material.set_shader_param("outer_color", sun_outer_color)
	sun_material.set_shader_param("latitude", sun_latitude)
	sun_material.set_shader_param("longitude", sun_longitude)
	sun_material.set_shader_param("use_horizon_cutoff", sun_horizon_cutoff)

	var sun_euler = Vector3( - sun_latitude, sun_longitude, 0.0)
	DirectionalLightManager.rotation_degrees = sun_euler

	DirectionalLightManager.set_shadow_enabled(GraphicsSettings.data.sun_shadows_enabled)
	DirectionalLightManager.set_shadow_color(sun_shadow_color)

	match (GraphicsSettings.data.sun_shadow_quality):
		0:
			DirectionalLightManager.set_directional_shadow_mode(DirectionalLight.SHADOW_ORTHOGONAL)
		1:
			DirectionalLightManager.set_directional_shadow_mode(DirectionalLight.SHADOW_PARALLEL_2_SPLITS)
		2:
			DirectionalLightManager.set_directional_shadow_mode(DirectionalLight.SHADOW_PARALLEL_4_SPLITS)

	DirectionalLightManager.set_blend_shadow_splits(GraphicsSettings.data.sun_shadow_blending)


func update_ambient_light()->void :
	var scope = Profiler.scope(self, "update_ambient_light", [])

	environment.ambient_light_color = ambient_light_color
	environment.ambient_light_energy = ambient_light_energy
	environment.ambient_light_sky_contribution = ambient_light_sky_contribution

func update_fog()->void :
	var scope = Profiler.scope(self, "update_fog", [])

	environment.fog_enabled = fog_enabled
	environment.fog_color = fog_color
	environment.fog_color.a = fog_intensity
	environment.fog_sun_amount = fog_sun_amount

	environment.fog_depth_enabled = fog_depth_enabled
	environment.fog_depth_begin = fog_depth_begin
	environment.fog_depth_end = fog_depth_end

	environment.fog_height_enabled = fog_height_enabled
	environment.fog_height_min = fog_height_min
	environment.fog_height_max = fog_height_max

func update_glow()->void :
	var scope = Profiler.scope(self, "update_glow", [])

	match (GraphicsSettings.data.glow_quality):
		0:
			environment.glow_bicubic_upscale = false
		1:
			environment.glow_bicubic_upscale = true

	environment.glow_enabled = GraphicsSettings.data.glow_enabled
	environment.glow_intensity = 1.1
	environment.glow_strength = 0.85
	environment.glow_hdr_threshold = 1
	environment.glow_hdr_luminance_cap = 16.0
	environment.glow_hdr_scale = 2
	environment.set("glow_levels/1", true)
	environment.set("glow_levels/2", true)
	environment.set("glow_levels/3", true)
	environment.set("glow_levels/4", true)
	environment.set("glow_levels/5", false)
	environment.set("glow_levels/6", false)
	environment.set("glow_levels/7", false)
	environment.set("glow_levels/8", false)

func update_ssr()->void :
	var scope = Profiler.scope(self, "update_ssr", [])

	environment.ss_reflections_enabled = GraphicsSettings.data.ssr_enabled


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	procedural_sky = ProceduralSky.new()
	panorama_sky = PanoramaSky.new()

	sun_material = preload("res://resources/material/workshop/sun.tres").duplicate()
	sun_mesh = QuadMesh.new()
	sun_mesh.size = Vector2(2, 2)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("brick_hill_environment_child"):
			remove_child(child)
			child.queue_free()

	sun_mesh_instance = MeshInstance.new()
	sun_mesh_instance.extra_cull_margin = 65536
	sun_mesh_instance.cast_shadow = MeshInstance.SHADOW_CASTING_SETTING_OFF
	sun_mesh_instance.mesh = sun_mesh
	sun_mesh_instance.material_override = sun_material
	sun_mesh_instance.set_meta("brick_hill_environment_child", true)
	add_child(sun_mesh_instance)

	if not GraphicsSettings.data.is_connected("local_shadows_enabled_changed", self, "update_sky"):
		GraphicsSettings.data.connect("local_shadows_enabled_changed", self, "update_sky")

	if not GraphicsSettings.data.is_connected("local_shadow_map_size_changed", self, "update_sky"):
		GraphicsSettings.data.connect("local_shadow_map_size_changed", self, "update_sky")

	if not GraphicsSettings.data.is_connected("sun_shadow_blending_changed", self, "update_sky"):
		GraphicsSettings.data.connect("sun_shadow_blending_changed", self, "update_sky")

	if not GraphicsSettings.data.is_connected("glow_enabled_changed", self, "update_glow"):
		GraphicsSettings.data.connect("glow_enabled_changed", self, "update_glow")

	if not GraphicsSettings.data.is_connected("glow_quality_changed", self, "update_glow"):
		GraphicsSettings.data.connect("glow_quality_changed", self, "update_glow")

	if not GraphicsSettings.data.is_connected("ssr_enabled_changed", self, "update_ssr"):
		GraphicsSettings.data.connect("ssr_enabled_changed", self, "update_ssr")

	update_sky()
	update_ambient_light()
	update_fog()
	update_glow()
	update_ssr()

	WorldEnvironmentManager.set_environment(environment)

	update_gravity()

func get_custom_categories()->Dictionary:
	return {
		"Gravity":{
			"":[
				"gravity_strength", 
				"gravity_direction"
			]
		}, 
		"Sky":{
			"":[
				"skybox_asset_id"
			], 
			"Sun":[
				"sun_enabled", 
				"sun_latitude", 
				"sun_longitude", 
				"sun_horizon_cutoff", 
				"sun_inner_color", 
				"sun_outer_color", 
			], 
			"Shadows":[
				"sun_shadow_color", 
			], 
			"Atmosphere":["sky_energy", "sky_color", "sky_curve"], 
			"Horizon":["horizon_upper_color", "horizon_lower_color"], 
			"Ground":["ground_color", "ground_curve"]
		}, 
		"Ambience":{
			"":[
				"ambient_light_color", 
				"ambient_light_energy", 
				"ambient_light_sky_contribution"
			]
		}, 
		"Fog":{
			"":[
				"fog_enabled", 
				"fog_color", 
				"fog_sun_amount"
			], 
			"Depth":[
				"fog_depth_enabled", 
				"fog_depth_begin", 
				"fog_depth_end", 
				"fog_intensity", 
			], 
			"Height":[
				"fog_height_enabled", 
				"fog_height_min", 
				"fog_height_max"
			]
		}
	}

func get_custom_property_names()->Dictionary:
	return {
		"gravity_strength":"Strength", 
		"gravity_direction":"Direction", 
		"skybox_asset_id":"Skybox", 
		"sun_visible":"Visible", 
		"sun_latitude":"Latitude", 
		"sun_longitude":"Longitude", 
		"sun_horizon_cutoff":"Horizon Cutoff", 
		"sun_inner_color":"Inner Color", 
		"sun_outer_color":"Outer Color", 
		"sun_shadow_color":"Color", 
		"sky_energy":"Energy", 
		"sky_color":"Color", 
		"sky_curve":"Curve", 
		"horizon_upper_color":"Upper Color", 
		"horizon_lower_color":"Lower Color", 
		"ground_color":"Color", 
		"ground_curve":"Curve", 
		"ambient_light_color":"Color", 
		"ambient_light_energy":"Energy", 
		"ambient_light_sky_contribution":"Sky Contribution", 
		"fog_enabled":"Enabled", 
		"fog_intensity":"Intensity", 
		"fog_color":"Color", 
		"fog_sun_amount":"Sun Amount", 
		"fog_depth_enabled":"Enabled", 
		"fog_depth_begin":"Start", 
		"fog_depth_end":"End", 
		"fog_height_enabled":"Enabled", 
		"fog_height_min":"Min", 
		"fog_height_max":"Max", 
	}

func get_group_properties()->Dictionary:
	return {
		"Sun":"sun_enabled", 
		"Depth":"fog_depth_enabled", 
		"Height":"fog_height_enabled", 
	}

func get_property_enabled(property:String)->bool:
	match property:
		"sun_latitude":
			return sun_enabled
		"sun_longitude":
			return sun_enabled
		"sun_inner_color":
			return sun_enabled
		"sun_outer_color":
			return sun_enabled
		"fog_color":
			return fog_enabled
		"fog_intensity":
			return fog_enabled
		"fog_sun_amount":
			return fog_enabled
		"fog_depth_enabled":
			return fog_enabled
		"fog_depth_begin":
			return fog_enabled and fog_depth_enabled
		"fog_depth_end":
			return fog_enabled and fog_depth_enabled
		"fog_height_enabled":
			return fog_enabled
		"fog_height_min":
			return fog_enabled and fog_height_enabled
		"fog_height_max":
			return fog_enabled and fog_height_enabled

	return true
