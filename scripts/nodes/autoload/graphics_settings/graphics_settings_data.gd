class_name GraphicsSettingsData
extends Resource
tool 

signal fullscreen_changed()

signal resolution_scale_factor_changed()
signal resolution_scale_filter_changed()

signal fxaa_enabled_changed()
signal msaa_enabled_changed()
signal msaa_mode_changed()

signal framelimit_enabled_changed()
signal framelimit_target_changed()

signal draw_distance_changed()

signal preset_changed()

signal local_shadows_enabled_changed()
signal local_shadow_map_size_changed()

signal sun_shadows_enabled_changed()
signal sun_shadow_quality_changed()
signal sun_shadow_blending_changed()

signal glow_enabled_changed()
signal glow_quality_changed()

signal ssr_enabled_changed()

signal shader_translucency_changed()
signal shader_refraction_changed()
signal shader_pom_quality_changed()

enum Preset{
	MIN = 0, 
	LOW = 1, 
	MEDIUM = 2, 
	HIGH = 3, 
	MAX = 4, 
	CUSTOM = 5
}

export (bool) var fullscreen: = false setget set_fullscreen

export (float, 0.25, 4.0, 0.05) var resolution_scale_factor: = 1.0 setget set_resolution_scale_factor
export (bool) var resolution_scale_filter: = true setget set_resolution_scale_filter

export (bool) var fxaa_enabled: = true setget set_fxaa_enabled

export (bool) var msaa_enabled: = false setget set_msaa_enabled
export (int, "2x MSAA,4x MSAA,8x MSAA,16x MSAA") var msaa_mode: = 1 setget set_msaa_mode

export (bool) var framelimit_enabled: = false setget set_framelimit_enabled
export (int, 15, 240, 1) var framelimit_target: = 60 setget set_framelimit_target

export (float, 10.0, 1000.0, 1.0) var draw_distance: = 500.0 setget set_draw_distance

export (int, "Min,Low,Medium,High,Max,Custom") var preset: = 3 setget set_preset

export (bool) var local_shadows_enabled: = true setget set_local_shadows_enabled
export (int, "1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192") var local_shadow_map_size: = 12 setget set_local_shadow_map_size

export (bool) var sun_shadows_enabled: = true setget set_sun_shadows_enabled
export (int, "Orthogonal,PSSM 2 Splits,PSSM 4 Splits") var sun_shadow_quality: = 2 setget set_sun_shadow_quality
export (bool) var sun_shadow_blending: = true setget set_sun_shadow_blending

export (bool) var glow_enabled: = true setget set_glow_enabled
export (int, "Medium,High") var glow_quality: = 1 setget set_glow_quality

export (bool) var ssr_enabled: = true setget set_ssr_enabled

export (bool) var shader_translucency: = true setget set_shader_translucency
export (bool) var shader_refraction: = true setget set_shader_refraction
export (int, "Off,Low,Medium,High") var shader_pom_quality: = 3 setget set_shader_pom_quality


func set_fullscreen(new_fullscreen:bool, _update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_fullscreen", [new_fullscreen, _update_preset])

	if fullscreen != new_fullscreen:
		fullscreen = new_fullscreen
		OS.set_window_fullscreen(fullscreen)
		emit_signal("fullscreen_changed")
		emit_signal("changed")

func set_resolution_scale_factor(new_resolution_scale_factor:float, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_resolution_scale_factor", [new_resolution_scale_factor, update_preset])

	if resolution_scale_factor != new_resolution_scale_factor:
		resolution_scale_factor = new_resolution_scale_factor
		emit_signal("resolution_scale_factor_changed")
		emit_signal("changed")

func set_resolution_scale_filter(new_resolution_scale_filter:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_resolution_scale_filter", [new_resolution_scale_filter, update_preset])

	if resolution_scale_filter != new_resolution_scale_filter:
		resolution_scale_filter = new_resolution_scale_filter
		emit_signal("resolution_scale_filter_changed")
		emit_signal("changed")

func set_fxaa_enabled(new_fxaa_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_fxaa_enabled", [new_fxaa_enabled, update_preset])

	if fxaa_enabled != new_fxaa_enabled:
		fxaa_enabled = new_fxaa_enabled
		emit_signal("fxaa_enabled_changed")
		emit_signal("changed")

func set_msaa_enabled(new_msaa_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_msaa_enabled", [new_msaa_enabled, update_preset])

	if msaa_enabled != new_msaa_enabled:
		msaa_enabled = new_msaa_enabled
		emit_signal("msaa_enabled_changed")
		emit_signal("changed")

func set_msaa_mode(new_msaa_mode:int, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_msaa_mode", [new_msaa_mode, update_preset])

	if msaa_mode != new_msaa_mode:
		msaa_mode = new_msaa_mode
		emit_signal("msaa_mode_changed")
		emit_signal("changed")

func set_framelimit_enabled(new_framelimit_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_framelimit_enabled", [new_framelimit_enabled, update_preset])

	if framelimit_enabled != new_framelimit_enabled:
		framelimit_enabled = new_framelimit_enabled
		update_framelimit_target()
		emit_signal("framelimit_enabled_changed")
		emit_signal("changed")

func set_framelimit_target(new_framelimit_target:int, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_framelimit_target", [new_framelimit_target, update_preset])

	if framelimit_target != new_framelimit_target:
		framelimit_target = new_framelimit_target
		update_framelimit_target()
		emit_signal("framelimit_target_changed")
		emit_signal("changed")

func update_framelimit_target()->void :
	var scope = Profiler.scope(self, "update_framelimit_target", [])

	if framelimit_enabled:
		Engine.target_fps = framelimit_target
	else :
		Engine.target_fps = 0

func set_draw_distance(new_draw_distance:float, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_draw_distance", [new_draw_distance, update_preset])

	if draw_distance != new_draw_distance:
		draw_distance = new_draw_distance
		emit_signal("draw_distance_changed")
		emit_signal("changed")

func set_preset(new_preset:int, ignore:bool = false)->void :
	var scope = Profiler.scope(self, "set_preset", [new_preset, ignore])

	if preset != new_preset:
		preset = new_preset

		match preset:
			Preset.MIN:
				set_local_shadows_enabled(false)
				set_local_shadow_map_size(10)

				set_sun_shadows_enabled(false)
				set_sun_shadow_quality(0)

				set_glow_enabled(false)
				set_glow_quality(0)

				set_ssr_enabled(false)

				set_shader_translucency(false)
				set_shader_refraction(false)
				set_shader_pom_quality(0)
			Preset.LOW:
				set_local_shadows_enabled(true)
				set_local_shadow_map_size(10)

				set_sun_shadows_enabled(true)
				set_sun_shadow_quality(0)

				set_glow_enabled(true)
				set_glow_quality(0)

				set_ssr_enabled(false)

				set_shader_translucency(false)
				set_shader_refraction(false)
				set_shader_pom_quality(1)
			Preset.MEDIUM:
				set_local_shadows_enabled(true)
				set_local_shadow_map_size(11)

				set_sun_shadows_enabled(true)
				set_sun_shadow_quality(1)

				set_glow_enabled(true)
				set_glow_quality(1)

				set_ssr_enabled(true)

				set_shader_translucency(true)
				set_shader_refraction(true)
				set_shader_pom_quality(2)
			Preset.HIGH:
				set_local_shadows_enabled(true)
				set_local_shadow_map_size(12)

				set_sun_shadows_enabled(true)
				set_sun_shadow_quality(2)

				set_glow_enabled(true)
				set_glow_quality(1)

				set_ssr_enabled(true)

				set_shader_translucency(true)
				set_shader_refraction(true)
				set_shader_pom_quality(3)
			Preset.MAX:
				set_local_shadows_enabled(true)
				set_local_shadow_map_size(13)

				set_sun_shadows_enabled(true)
				set_sun_shadow_quality(3)

				set_glow_enabled(true)
				set_glow_quality(1)

				set_ssr_enabled(true)

				set_shader_translucency(true)
				set_shader_refraction(true)
				set_shader_pom_quality(3)

	emit_signal("preset_changed")
	emit_signal("changed")

func set_local_shadows_enabled(new_local_shadows_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_local_shadows_enabled", [new_local_shadows_enabled, update_preset])

	if local_shadows_enabled != new_local_shadows_enabled:
		local_shadows_enabled = new_local_shadows_enabled
		emit_signal("local_shadows_enabled_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_local_shadow_map_size(new_local_shadow_map_size:int, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_local_shadow_map_size", [new_local_shadow_map_size, update_preset])

	if local_shadow_map_size != new_local_shadow_map_size:
		local_shadow_map_size = new_local_shadow_map_size
		emit_signal("local_shadow_map_size_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_sun_shadows_enabled(new_sun_shadows_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_sun_shadows_enabled", [new_sun_shadows_enabled, update_preset])

	if sun_shadows_enabled != new_sun_shadows_enabled:
		sun_shadows_enabled = new_sun_shadows_enabled
		emit_signal("sun_shadows_enabled_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_sun_shadow_quality(new_sun_shadow_quality:int, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_sun_shadow_quality", [new_sun_shadow_quality, update_preset])

	if sun_shadow_quality != new_sun_shadow_quality:
		sun_shadow_quality = new_sun_shadow_quality
		emit_signal("sun_shadow_quality_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_sun_shadow_blending(new_sun_shadow_blending:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_sun_shadow_blending", [new_sun_shadow_blending, update_preset])

	if sun_shadow_blending != new_sun_shadow_blending:
		sun_shadow_blending = new_sun_shadow_blending
		emit_signal("sun_shadow_blending_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_glow_enabled(new_glow_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_glow_enabled", [new_glow_enabled, update_preset])

	if glow_enabled != new_glow_enabled:
		glow_enabled = new_glow_enabled
		emit_signal("glow_enabled_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_glow_quality(new_glow_quality:int, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_glow_quality", [new_glow_quality, update_preset])

	if glow_quality != new_glow_quality:
		glow_quality = new_glow_quality
		emit_signal("glow_quality_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_ssr_enabled(new_ssr_enabled:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_ssr_enabled", [new_ssr_enabled, update_preset])

	if ssr_enabled != new_ssr_enabled:
		ssr_enabled = new_ssr_enabled
		emit_signal("ssr_enabled_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_shader_pom_quality(new_shader_pom_quality:int, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_shader_pom_quality", [new_shader_pom_quality, update_preset])

	if shader_pom_quality != new_shader_pom_quality:
		shader_pom_quality = new_shader_pom_quality
		emit_signal("shader_pom_quality_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_shader_translucency(new_shader_translucency:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_shader_translucency", [new_shader_translucency, update_preset])

	if shader_translucency != new_shader_translucency:
		shader_translucency = new_shader_translucency
		emit_signal("shader_translucency_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)

func set_shader_refraction(new_shader_refraction:bool, update_preset:bool = false)->void :
	var scope = Profiler.scope(self, "set_shader_refraction", [new_shader_refraction, update_preset])

	if shader_refraction != new_shader_refraction:
		shader_refraction = new_shader_refraction
		emit_signal("shader_refraction_changed")
		emit_signal("changed")
		if update_preset:
			set_preset(Preset.CUSTOM)


func get_custom_categories()->Dictionary:
	return {
		"":{
			"":["preset"]
		}, 
		"Display":{
			"":[
				"fullscreen", 
			], 
			"Framerate Limit":[
				"framelimit_enabled", 
				"framelimit_target"
			], 
			"Anti-Aliasing":[
				"fxaa_enabled", 
				"msaa_enabled", 
				"msaa_mode"
			], 
			"Resolution Scale":[
				"resolution_scale_factor", 
				"resolution_scale_filter"
			]
		}, 
		"Camera":{
			"":[
				"draw_distance", 
			]
		}, 
		"Quality":{
			"":["preset"], 
			"Local Shadows":[
				"local_shadows_enabled", 
				"local_shadow_map_size", 
			], 
			"Sun Shadows":[
				"sun_shadows_enabled", 
				"sun_shadow_quality", 
				"sun_shadow_blending", 
			], 
			"Glow":[
				"glow_enabled", 
				"glow_quality", 
			], 
			"Screen-space Reflection":[
				"ssr_enabled", 
			], 
			"Parallax Occlusion Mapping":[
				"pom_min_layers", 
				"pom_max_layers"
			], 
			"Brick Shader":[
				"shader_translucency", 
				"shader_refraction", 
				"shader_pom_quality"
			]
		}
	}

func get_custom_property_names()->Dictionary:
	return {
		"fxaa_enabled":"FXAA Enabled", 
		"msaa_enabled":"MSAA Enabled", 
		"msaa_mode":"MSAA Mode", 
		"framelimit_enabled":"Enabled", 
		"framelimit_target":"Target", 
		"resolution_scale_factor":"Factor", 
		"resolution_scale_filter":"Filter", 
		"local_shadows_enabled":"Enabled", 
		"local_shadow_map_size":"Shadow Map Size", 
		"sun_shadows_enabled":"Enabled", 
		"sun_shadow_quality":"Quality", 
		"sun_shadow_blending":"Blend Splits", 
		"glow_enabled":"Enabled", 
		"glow_quality":"Quality", 
		"ssr_enabled":"Enabled", 
		"pom_min_layers":"Minimum Layers", 
		"pom_max_layers":"Maximum Layers", 
		"shader_translucency":"Translucency", 
		"shader_refraction":"Refraction", 
		"shader_pom_quality":"Parallax Occlusion Mapping Quality"
	}

func get_group_properties()->Dictionary:
	return {
		"Framerate Limit":"framelimit_enabled", 
		"Local Shadows":"local_shadows_enabled", 
		"Sun Shadows":"sun_shadows_enabled", 
		"Glow":"glow_enabled", 
		"Screen-space Reflection":"ssr_enabled", 
	}

func get_property_enabled(property:String)->bool:
	match property:
		"msaa_mode":
			return msaa_enabled
		"framelimit_target":
			return framelimit_enabled
		"local_shadow_map_size":
			return local_shadows_enabled
		"sun_shadow_quality":
			return sun_shadows_enabled
		"sun_shadow_blending":
			return sun_shadows_enabled
		"glow_quality":
			return glow_enabled

	return true
