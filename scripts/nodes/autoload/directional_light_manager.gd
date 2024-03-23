extends Spatial
tool 

enum DirectionalLightMode{
	Optimized = 0, 
	Stable = 1
}

export (int) var mode = DirectionalLightMode.Optimized setget set_mode

var directional:DirectionalLight
var omni:OmniLight

func set_mode(new_mode:int)->void :
	var scope = Profiler.scope(self, "set_mode", [new_mode])

	if mode != new_mode:
		mode = new_mode
		if is_inside_tree():
			update_lights()

func set_light_energy(new_light_energy:float)->void :
	var scope = Profiler.scope(self, "set_light_energy", [new_light_energy])

	directional.light_energy = new_light_energy
	omni.light_energy = new_light_energy

func set_light_indirect_energy(new_light_indirect_energy:float)->void :
	var scope = Profiler.scope(self, "set_light_indirect_energy", [new_light_indirect_energy])

	directional.light_indirect_energy = new_light_indirect_energy
	omni.light_indirect_energy = new_light_indirect_energy

func set_light_color(new_light_color:Color)->void :
	var scope = Profiler.scope(self, "set_light_color", [new_light_color])

	directional.light_color = new_light_color
	omni.light_color = new_light_color

func set_shadow_color(new_shadow_color:Color)->void :
	var scope = Profiler.scope(self, "set_shadow_color", [new_shadow_color])

	directional.shadow_color = new_shadow_color
	omni.shadow_color = new_shadow_color

func set_shadow_bias(new_shadow_bias:float)->void :
	var scope = Profiler.scope(self, "set_shadow_bias", [new_shadow_bias])

	directional.shadow_bias = new_shadow_bias
	omni.shadow_bias = new_shadow_bias

func set_shadow_offset(new_shadow_offset:float)->void :
	var scope = Profiler.scope(self, "set_shadow_offset", [new_shadow_offset])

	omni.translation.z = new_shadow_offset
	omni.omni_range = new_shadow_offset * 2.0

func set_blend_shadow_splits(new_blend_shadow_splits:bool)->void :
	var scope = Profiler.scope(self, "set_blend_shadow_splits", [new_blend_shadow_splits])

	directional.directional_shadow_blend_splits = new_blend_shadow_splits

func set_shadow_detail(new_shadow_detail:int)->void :
	var scope = Profiler.scope(self, "set_shadow_detail", [new_shadow_detail])

	match new_shadow_detail:
		0:
			omni.omni_shadow_detail = OmniLight.SHADOW_DETAIL_HORIZONTAL
		1:
			omni.omni_shadow_detail = OmniLight.SHADOW_DETAIL_VERTICAL

func set_shadow_enabled(new_shadow_enabled:bool)->void :
	var scope = Profiler.scope(self, "set_shadow_enabled", [new_shadow_enabled])

	directional.shadow_enabled = new_shadow_enabled
	omni.shadow_enabled = new_shadow_enabled

func set_directional_shadow_mode(new_directional_shadow_mode:int)->void :
	var scope = Profiler.scope(self, "set_directional_shadow_mode", [new_directional_shadow_mode])

	directional.directional_shadow_mode = new_directional_shadow_mode

func update_lights()->void :
	var scope = Profiler.scope(self, "update_lights", [])

	directional.visible = mode == DirectionalLightMode.Optimized
	omni.visible = mode == DirectionalLightMode.Stable

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	for child in get_children():
		if child.has_meta("directional_light_manager_child"):
			remove_child(child)
			child.queue_free()

	directional = DirectionalLight.new()
	omni = OmniLight.new()

	directional.directional_shadow_max_distance = 0.0

	directional.light_bake_mode = Light.BAKE_INDIRECT
	omni.light_bake_mode = Light.BAKE_INDIRECT

	add_child(directional)
	add_child(omni)

	omni.translation.z = 2048
	omni.rotation_degrees.z = 90
	omni.shadow_bias = 8
	omni.omni_range = 4096
	omni.omni_attenuation = 0
	omni.omni_shadow_mode = OmniLight.SHADOW_DUAL_PARABOLOID
	omni.omni_shadow_detail = OmniLight.SHADOW_DETAIL_VERTICAL

	update_lights()
