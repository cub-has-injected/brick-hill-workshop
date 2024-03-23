class_name BrickHillViewport
extends Viewport

export (bool) var ignore_shadows: = false

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	GraphicsSettings.data.connect("fxaa_enabled_changed", self, "update_fxaa")
	GraphicsSettings.data.connect("msaa_enabled_changed", self, "update_msaa")
	GraphicsSettings.data.connect("msaa_mode_changed", self, "update_anti_aliasing")
	GraphicsSettings.data.connect("local_shadows_enabled_changed", self, "update_shadow_atlas_size")
	GraphicsSettings.data.connect("local_shadow_map_size_changed", self, "update_shadow_atlas_size")

	update_fxaa()
	update_msaa()
	update_shadow_atlas_size()

func update_fxaa()->void :
	var scope = Profiler.scope(self, "update_fxaa", [])

	set_use_fxaa(GraphicsSettings.data.fxaa_enabled)

func update_msaa()->void :
	var scope = Profiler.scope(self, "update_msaa", [])

	if GraphicsSettings.data.msaa_enabled:
		match GraphicsSettings.data.msaa_mode:
			0:
				set_msaa(Viewport.MSAA_2X)
			1:
				set_msaa(Viewport.MSAA_4X)
			2:
				set_msaa(Viewport.MSAA_8X)
			3:
				set_msaa(Viewport.MSAA_16X)
	else :
		set_msaa(Viewport.MSAA_DISABLED)

func update_shadow_atlas_size()->void :
	var scope = Profiler.scope(self, "update_shadow_atlas_size", [])

	if ignore_shadows:
		return 

	if GraphicsSettings.data.local_shadows_enabled:
		set_shadow_atlas_size(pow(2, GraphicsSettings.data.local_shadow_map_size))
	else :
		set_shadow_atlas_size(0)
