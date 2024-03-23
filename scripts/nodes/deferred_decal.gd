class_name DeferredDecal
extends MeshInstance
tool 


var extents: = Vector3.ONE setget set_extents
var decal_albedo:Texture = preload("res://resources/texture/surfaces/uv_test_512.png") setget set_decal_albedo
var decal_normal:Texture = null setget set_decal_normal
var albedo: = Color.white setget set_albedo
var metallic: = 0.0 setget set_metallic
var roughness: = 1.0 setget set_roughness
var cull_normal: = true setget set_cull_normal
var cull_normal_min: = 0.1 setget set_cull_normal_min
var cull_normal_max: = 0.25 setget set_cull_normal_max
var draw_debug: = true setget set_draw_debug


var cube_mesh:CubeMesh
var decal_material:ShaderMaterial
var debug_draw:ImmediateGeometry


func set_extents(new_extents:Vector3)->void :
	var scope = Profiler.scope(self, "set_extents", [new_extents])

	if extents != new_extents:
		extents = new_extents
		update_extents()

func set_decal_albedo(new_decal_albedo:Texture)->void :
	var scope = Profiler.scope(self, "set_decal_albedo", [new_decal_albedo])

	if decal_albedo != new_decal_albedo:
		decal_albedo = new_decal_albedo
		update_decal_albedo()

func set_decal_normal(new_decal_normal:Texture)->void :
	var scope = Profiler.scope(self, "set_decal_normal", [new_decal_normal])

	if decal_normal != new_decal_normal:
		decal_normal = new_decal_normal

func set_albedo(new_albedo:Color)->void :
	var scope = Profiler.scope(self, "set_albedo", [new_albedo])

	if albedo != new_albedo:
		albedo = new_albedo
		albedo_changed()

func set_metallic(new_metallic:float)->void :
	var scope = Profiler.scope(self, "set_metallic", [new_metallic])

	if metallic != new_metallic:
		metallic = new_metallic
		metallic_changed()

func set_roughness(new_roughness:float)->void :
	var scope = Profiler.scope(self, "set_roughness", [new_roughness])

	if roughness != new_roughness:
		roughness = new_roughness
		roughness_changed()

func set_cull_normal(new_cull_normal:bool)->void :
	var scope = Profiler.scope(self, "set_cull_normal", [new_cull_normal])

	if cull_normal != new_cull_normal:
		cull_normal = new_cull_normal
		update_cull_normal()

func set_cull_normal_min(new_cull_normal_min:float)->void :
	var scope = Profiler.scope(self, "set_cull_normal_min", [new_cull_normal_min])

	if cull_normal_min != new_cull_normal_min:
		cull_normal_min = new_cull_normal_min
		update_cull_normal_min()

func set_cull_normal_max(new_cull_normal_max:float)->void :
	var scope = Profiler.scope(self, "set_cull_normal_max", [new_cull_normal_max])

	if cull_normal_max != new_cull_normal_max:
		cull_normal_max = new_cull_normal_max
		update_cull_normal_max()

func set_draw_debug(new_draw_debug:bool)->void :
	var scope = Profiler.scope(self, "set_draw_debug", [new_draw_debug])

	if draw_debug != new_draw_debug:
		draw_debug = new_draw_debug
		update_debug_draw()


func update_extents()->void :
	var scope = Profiler.scope(self, "update_extents", [])

	cube_mesh.set_size(extents * 2.0)
	decal_material.set_shader_param("extents", extents)
	update_debug_draw()

func update_decal_albedo()->void :
	var scope = Profiler.scope(self, "update_decal_albedo", [])

	decal_material.set_shader_param("decal_albedo", decal_albedo)

func update_decal_normal()->void :
	var scope = Profiler.scope(self, "update_decal_normal", [])

	decal_material.set_shader_param("decal_normal", decal_normal)

func albedo_changed()->void :
	var scope = Profiler.scope(self, "albedo_changed", [])

	decal_material.set_shader_param("albedo", albedo)

func metallic_changed()->void :
	var scope = Profiler.scope(self, "metallic_changed", [])

	decal_material.set_shader_param("metallic", metallic)

func roughness_changed()->void :
	var scope = Profiler.scope(self, "roughness_changed", [])

	decal_material.set_shader_param("roughness", roughness)

func update_cull_normal()->void :
	var scope = Profiler.scope(self, "update_cull_normal", [])

	decal_material.set_shader_param("cull_normal", cull_normal)
	update_debug_draw()

func update_cull_normal_min()->void :
	var scope = Profiler.scope(self, "update_cull_normal_min", [])

	decal_material.set_shader_param("cull_normal_min", cull_normal_min)

func update_cull_normal_max()->void :
	var scope = Profiler.scope(self, "update_cull_normal_max", [])

	decal_material.set_shader_param("cull_normal_max", cull_normal_max)

func update_debug_draw()->void :
	var scope = Profiler.scope(self, "update_debug_draw", [])

	debug_draw.clear()

	if draw_debug:
		debug_draw.begin(Mesh.PRIMITIVE_LINES)
		debug_draw.set_color(Color.yellow if cull_normal else Color.red)

		debug_draw_extents()

		debug_draw_arrow(debug_draw, Transform(Basis.IDENTITY, Vector3.UP))
		debug_draw_arrow(debug_draw, Transform(Basis.IDENTITY, Vector3.DOWN))
		debug_draw_arrow(debug_draw, Transform(Basis(Vector3.FORWARD, deg2rad( - 90)), Vector3.LEFT))
		debug_draw_arrow(debug_draw, Transform(Basis(Vector3.FORWARD, deg2rad(90)), Vector3.RIGHT))

		debug_draw.end()


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	cube_mesh = CubeMesh.new()
	set_mesh(cube_mesh)

	decal_material = preload("res://resources/material/workshop/deferred_decal.tres").duplicate()
	set_material_override(decal_material)

	for child in get_children():
		if child.has_meta("deferred_decal_child"):
			remove_child(child)
			child.queue_free()

	var debug_draw_material: = SpatialMaterial.new()
	debug_draw_material.vertex_color_use_as_albedo = true
	debug_draw_material.flags_no_depth_test = true
	debug_draw_material.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_DISABLED
	debug_draw_material.render_priority = SpatialMaterial.RENDER_PRIORITY_MAX
	debug_draw_material.flags_unshaded = true

	debug_draw = ImmediateGeometry.new()
	debug_draw.set_material_override(debug_draw_material)
	debug_draw.set_meta("deferred_decal_child", true)
	add_child(debug_draw)

	update_extents()
	update_decal_albedo()
	update_decal_normal()
	update_cull_normal()
	update_cull_normal_min()
	update_cull_normal_max()

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	return [
		{
			"name":"DeferredDecal", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_CATEGORY
		}, 
		{
			"name":"extents", 
			"type":TYPE_VECTOR3
		}, 
		{
			"name":"Culling", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_GROUP
		}, 
		{
			"name":"cull_normal", 
			"type":TYPE_BOOL
		}, 
		{
			"name":"cull_normal_min", 
			"type":TYPE_REAL
		}, 
		{
			"name":"cull_normal_max", 
			"type":TYPE_REAL
		}, 
		{
			"name":"Textures", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_GROUP
		}, 
		{
			"name":"decal_albedo", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"Texture"
		}, 
		{
			"name":"decal_normal", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"Texture"
		}, 
		{
			"name":"Material", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_GROUP
		}, 
		{
			"name":"metallic", 
			"type":TYPE_REAL
		}, 
		{
			"name":"roughness", 
			"type":TYPE_REAL
		}
	]


func debug_draw_extents()->void :
	var scope = Profiler.scope(self, "debug_draw_extents", [])

	
	debug_draw.add_vertex(Vector3(1, 1, 1) * extents)
	debug_draw.add_vertex(Vector3(1, 1, - 1) * extents)

	debug_draw.add_vertex(Vector3(1, 1, - 1) * extents)
	debug_draw.add_vertex(Vector3( - 1, 1, - 1) * extents)

	debug_draw.add_vertex(Vector3( - 1, 1, - 1) * extents)
	debug_draw.add_vertex(Vector3( - 1, 1, 1) * extents)

	debug_draw.add_vertex(Vector3( - 1, 1, 1) * extents)
	debug_draw.add_vertex(Vector3(1, 1, 1) * extents)

	
	debug_draw.add_vertex(Vector3(1, - 1, 1) * extents)
	debug_draw.add_vertex(Vector3(1, - 1, - 1) * extents)

	debug_draw.add_vertex(Vector3(1, - 1, - 1) * extents)
	debug_draw.add_vertex(Vector3( - 1, - 1, - 1) * extents)

	debug_draw.add_vertex(Vector3( - 1, - 1, - 1) * extents)
	debug_draw.add_vertex(Vector3( - 1, - 1, 1) * extents)

	debug_draw.add_vertex(Vector3( - 1, - 1, 1) * extents)
	debug_draw.add_vertex(Vector3(1, - 1, 1) * extents)

	
	debug_draw.add_vertex(Vector3(1, 1, 1) * extents)
	debug_draw.add_vertex(Vector3(1, - 1, 1) * extents)

	debug_draw.add_vertex(Vector3(1, 1, - 1) * extents)
	debug_draw.add_vertex(Vector3(1, - 1, - 1) * extents)

	debug_draw.add_vertex(Vector3( - 1, 1, - 1) * extents)
	debug_draw.add_vertex(Vector3( - 1, - 1, - 1) * extents)

	debug_draw.add_vertex(Vector3( - 1, 1, 1) * extents)
	debug_draw.add_vertex(Vector3( - 1, - 1, 1) * extents)

func debug_draw_arrow(immediate_geometry:ImmediateGeometry, transform:Transform)->void :
	var scope = Profiler.scope(self, "debug_draw_arrow", [immediate_geometry, transform])

	immediate_geometry.add_vertex(transform.xform(Vector3(0, 0, 0.5)) * extents)
	immediate_geometry.add_vertex(transform.xform(Vector3(0, 0, - 0.5)) * extents)

	immediate_geometry.add_vertex(transform.xform(Vector3(0, 0, - 0.5)) * extents)
	immediate_geometry.add_vertex(transform.xform(Vector3( - 0.5, 0, 0)) * extents)

	immediate_geometry.add_vertex(transform.xform(Vector3(0, 0, - 0.5)) * extents)
	immediate_geometry.add_vertex(transform.xform(Vector3(0.5, 0, 0)) * extents)
