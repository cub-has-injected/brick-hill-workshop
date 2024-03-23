class_name BrickHillBrickObject
extends BrickHillLightObject
tool 

signal shape_changed()

const MAX_FACES: = 7

enum SurfaceType{
	FLAT = 0, 
	SMOOTH = 8, 
	STUDDED = 1, 
	INLETS = 1 | 4, 
	ALTERNATING = 1 | 2, 
	ALTERNATING_FLIPPED = 1 | 2 | 4
}

enum MaterialType{
	PLASTIC = 0, 
	CONCRETE = 1, 
	CRYSTAL = 2, 
	ICE = 3, 
	STONE = 4, 
	WOOD = 5, 
	TEST = 6
}


export (int, "Cube,Cylinder,Cylinder (Half),Cylinder (Quarter),Inverse Cylinder (Half),Inverse Cylinder(Quarter),Sphere,Sphere (Half),Sphere (Quarter),Sphere (Eigth),Wedge,Corner,Edge") var shape: = 0 setget set_shape
export (Color) var albedo: = Color.white setget set_albedo
export (Color) var emission_color: = Color.white setget set_emission_color
export (float, 0.0, 16.0, 0.1) var emission_energy: = 0.0 setget set_emission_energy
export (int, "Plastic,Concrete,Crystal,Ice,Stone,Wood,Test") var material: = 0 setget set_material
export (PoolByteArray) var surfaces:PoolByteArray setget set_surfaces
export (float, 0.0, 1.0, 0.01) var opacity: = 1.0 setget set_opacity
export (float, 0.0, 0.9, 0.01) var roughness: = 0.7 setget set_roughness
export (float, 0.0, 0.9, 0.01) var metallic: = 0.0 setget set_metallic
export (float, 0.0, 0.4, 0.01) var refraction: = 0.0 setget set_refraction


export (PoolColorArray) var colors:PoolColorArray
export (Vector2) var uv_offset: = Vector2.ZERO setget set_uv_offset

var physics_interpolator:PhysicsInterpolator
var brick_instance:BrickInstance


func set_shape(new_shape:int)->void :
	var scope = Profiler.scope(self, "set_shape", [new_shape])

	if shape != new_shape:
		shape = new_shape
		if is_inside_tree():
			shape_changed()

func set_material(new_material:int)->void :
	var scope = Profiler.scope(self, "set_material", [new_material])

	if PRINT:
		print_debug("%s set material to %s" % [get_name(), new_material])

	if material != new_material:
		material = new_material
		if is_inside_tree():
			material_changed()

func set_uv_offset(new_uv_offset:Vector2)->void :
	var scope = Profiler.scope(self, "set_uv_offset", [new_uv_offset])

	if PRINT:
		print_debug("%s set UV offset to %s" % [get_name(), new_uv_offset])

	if uv_offset != new_uv_offset:
		uv_offset = new_uv_offset
		if is_inside_tree():
			uv_offset_changed()

func set_surfaces(new_surfaces:PoolByteArray)->void :
	var scope = Profiler.scope(self, "set_surfaces", [new_surfaces])

	if PRINT:
		print_debug("%s set surfaces to %s" % [get_name(), new_surfaces])

	if surfaces != new_surfaces:
		surfaces = new_surfaces
		if is_inside_tree():
			surfaces_changed()

func set_surface(new_surface:int, surface_idx:int)->void :
	var scope = Profiler.scope(self, "set_surface", [surface_idx])

	if PRINT:
		print_debug("%s set surface %s to %s" % [get_name(), surface_idx, new_surface])

	if surfaces[surface_idx] != new_surface:
		surfaces[surface_idx] = new_surface
		if is_inside_tree():
			surfaces_changed()

func set_opacity(new_opacity:float)->void :
	var scope = Profiler.scope(self, "set_opacity", [new_opacity])

	if PRINT:
		print_debug("%s set opacity to %s" % [get_name(), new_opacity])

	if opacity != new_opacity:
		opacity = new_opacity
		if is_inside_tree():
			opacity_changed()

func set_albedo(new_albedo:Color)->void :
	var scope = Profiler.scope(self, "set_albedo", [new_albedo])

	if PRINT:
		print_debug("%s set albedo to %s" % [get_name(), new_albedo])

	if albedo != new_albedo:
		albedo = new_albedo
		if is_inside_tree():
			albedo_changed()

func set_emission_color(new_emission_color:Color)->void :
	var scope = Profiler.scope(self, "set_emission_color", [new_emission_color])

	if PRINT:
		print_debug("%s set emission_color to %s" % [get_name(), new_emission_color])

	if emission_color != new_emission_color:
		emission_color = new_emission_color
		if is_inside_tree():
			emission_changed()

func set_emission_energy(new_emission_energy:float)->void :
	var scope = Profiler.scope(self, "set_emission_energy", [new_emission_energy])

	if PRINT:
		print_debug("%s set emission_energy to %s" % [get_name(), new_emission_energy])

	if emission_energy != new_emission_energy:
		emission_energy = new_emission_energy
		if is_inside_tree():
			emission_changed()

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

func _set(property:String, value)->bool:
	var scope = Profiler.scope(self, "_set", [property, value])

	if property == "visible":
		if brick_instance:
			brick_instance.call_deferred("update_visible")
	return false


func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Brick"

func get_materials()->Array:
	var scope = Profiler.scope(self, "get_materials")

	if PRINT:
		print_debug("%s get materials" % [get_name()])

	return []

func get_bounds()->AABB:
	var scope = Profiler.scope(self, "get_bounds")

	return AABB( - size * 0.5, size)

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	.get_hovered_face_idx(normal)
	normal = global_transform.basis.xform_inv(normal)
	return ModelManager.get_brick_mesh_hovered_face_idx(shape, normal)

func get_tree_icon(highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon", [highlight])

	var icons: = BrickHillResources.ICONS
	match shape:
		ModelManager.BrickMeshType.CUBE:
			return icons.tree_highlight_cube if highlight else icons.tree_cube
		ModelManager.BrickMeshType.CYLINDER:
			return icons.tree_highlight_round if highlight else icons.tree_round
		ModelManager.BrickMeshType.CYLINDER_HALF:
			return icons.tree_highlight_round if highlight else icons.tree_round
		ModelManager.BrickMeshType.CYLINDER_QUARTER:
			return icons.tree_highlight_round if highlight else icons.tree_round
		ModelManager.BrickMeshType.INVERSE_CYLINDER_HALF:
			return icons.tree_highlight_special if highlight else icons.tree_special
		ModelManager.BrickMeshType.INVERSE_CYLINDER_QUARTER:
			return icons.tree_highlight_special if highlight else icons.tree_special
		ModelManager.BrickMeshType.SPHERE:
			return icons.tree_highlight_special if highlight else icons.tree_special
		ModelManager.BrickMeshType.SPHERE_HALF:
			return icons.tree_highlight_special if highlight else icons.tree_special
		ModelManager.BrickMeshType.SPHERE_QUARTER:
			return icons.tree_highlight_special if highlight else icons.tree_special
		ModelManager.BrickMeshType.SPHERE_EIGTH:
			return icons.tree_highlight_special if highlight else icons.tree_special
		ModelManager.BrickMeshType.WEDGE:
			return icons.tree_highlight_wedge if highlight else icons.tree_wedge
		ModelManager.BrickMeshType.WEDGE_CORNER:
			return icons.tree_highlight_wedge if highlight else icons.tree_wedge
		ModelManager.BrickMeshType.WEDGE_EDGE:
			return icons.tree_highlight_wedge if highlight else icons.tree_wedge

	return null


func object_mode_changed()->void :
	var scope = Profiler.scope(self, "object_mode_changed")

	.object_mode_changed()
	brick_instance.use_in_baked_light = object_mode == BrickHillUtil.ObjectMode.STATIC
	if frozen:
		collision_shape.convex = true
	else :
		match shape:
			ModelManager.BrickMeshType.INVERSE_CYLINDER_HALF:
				collision_shape.convex = false
			ModelManager.BrickMeshType.INVERSE_CYLINDER_QUARTER:
				collision_shape.convex = false
			_:
				collision_shape.convex = true

func size_changed()->void :
	var scope = Profiler.scope(self, "size_changed")

	.size_changed()
	update_physics_interpolator()

func flip_changed()->void :
	var scope = Profiler.scope(self, "flip_changed")

	.flip_changed()
	update_physics_interpolator()

func update_physics_interpolator()->void :
	var scope = Profiler.scope(self, "update_physics_interpolator")

	physics_interpolator.scale = size

	if flip[0]:
		physics_interpolator.scale.x *= - 1

	if flip[1]:
		physics_interpolator.scale.y *= - 1

	if flip[2]:
		physics_interpolator.scale.z *= - 1


func shape_changed()->void :
	var scope = Profiler.scope(self, "shape_changed")

	brick_instance.mesh_type = shape

	var fill_surface_from = surfaces.size()
	var fill_surface:int

	if fill_surface_from > 0:
		fill_surface = surfaces[ - 1]

	surfaces.resize(ModelManager.get_brick_mesh_surface_count(shape))

	if fill_surface_from > 0:
		for i in range(fill_surface_from, surfaces.size()):
			surfaces[i] = fill_surface

	surfaces_changed()
	property_list_changed_notify()
	emit_signal("shape_changed")

func material_changed()->void :
	var scope = Profiler.scope(self, "material_changed")

	brick_instance.material_idx = material

func surfaces_changed()->void :
	var scope = Profiler.scope(self, "surfaces_changed")

	brick_instance.surface_palette = surfaces

func opacity_changed()->void :
	var scope = Profiler.scope(self, "opacity_changed")

	brick_instance.opacity = opacity

func albedo_changed()->void :
	var scope = Profiler.scope(self, "albedo_changed")

	var color_array: = PoolColorArray()
	for _i in range(0, MAX_FACES):
		color_array.append(albedo)
	brick_instance.albedo_palette = color_array

func emission_changed()->void :
	var scope = Profiler.scope(self, "emission_changed")

	var color_array: = PoolColorArray()
	var color = emission_color * emission_energy
	for _i in range(0, MAX_FACES):
		color_array.append(color)
	brick_instance.emission_palette = color_array

func roughness_changed()->void :
	var scope = Profiler.scope(self, "roughness_changed")

	brick_instance.roughness = roughness

func metallic_changed()->void :
	var scope = Profiler.scope(self, "metallic_changed")

	brick_instance.metallic = metallic

func uv_offset_changed()->void :
	var scope = Profiler.scope(self, "uv_offset_changed")

	brick_instance.uv_offset = uv_offset

func refraction_changed()->void :
	var scope = Profiler.scope(self, "refraction_changed")

	brick_instance.refraction = refraction


func create_collision_shape()->CollisionShape:
	var scope = Profiler.scope(self, "create_collision_shape")

	return BrickCollisionShape.new()

func update_collision()->void :
	var scope = Profiler.scope(self, "update_collision")

	.update_collision()

	collision_shape.mesh_type = shape


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	._enter_tree()

	for child in rigid_body.get_children():
		if child.has_meta("brick_object_child"):
			rigid_body.remove_child(child)
			child.queue_free()

	physics_interpolator = PhysicsInterpolator.new()
	physics_interpolator.name = "PhysicsInterpolator"
	physics_interpolator.set_meta("brick_object_child", true)
	rigid_body.add_child(physics_interpolator)

	brick_instance = BrickInstance.new()
	brick_instance.name = "BrickInstance"
	physics_interpolator.add_child(brick_instance)

	var collision_object_input = CollisionObjectInput.new()
	rigid_body.add_child(collision_object_input)

	var selectable = Selectable.new()
	rigid_body.add_child(selectable)
	selectable.selection_path = selectable.get_path_to(self)

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree")

	request_ready()

func _ready()->void :
	var scope = Profiler.scope(self, "_ready")

	
	
	if colors.size() != 0:
		var avg_color = Color.black
		for color in colors:
			avg_color += color
		avg_color /= colors.size()
		albedo = avg_color
		colors = PoolColorArray()

	physics_interpolator.set_active(false)

func initial_update()->void :
	var scope = Profiler.scope(self, "initial_update")

	.initial_update()

	shape_changed()
	albedo_changed()
	emission_changed()
	material_changed()
	uv_offset_changed()
	opacity_changed()
	roughness_changed()
	metallic_changed()
	refraction_changed()
	surfaces_changed()

func freeze()->void :
	var scope = Profiler.scope(self, "freeze")

	.freeze()
	physics_interpolator.active = false

func unfreeze()->void :
	var scope = Profiler.scope(self, "unfreeze")

	.unfreeze()
	physics_interpolator.active = not anchored

func hovered()->void :
	brick_instance.hovered = true

func unhovered()->void :
	brick_instance.hovered = false

func selected()->void :
	brick_instance.selected = true

func unselected()->void :
	brick_instance.selected = false

func physics_body_sleeping_state_changed()->void :
	var scope = Profiler.scope(self, "physics_body_sleeping_state_changed")

	physics_interpolator.set_ticking( not anchored and not rigid_body.sleeping)

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Brick"] = {
		"":[
			"shape"
		], 
		"Appearance":[
			"albedo", 
			"emission_color", 
			"emission_energy", 
			"surfaces", 
			"material", 
			"opacity", 
			"roughness", 
			"metallic", 
			"refraction", 
		]
	}
	return categories

func get_custom_property_names()->Dictionary:
	var custom_property_names = .get_custom_property_names()
	custom_property_names["albedo"] = "Color"
	custom_property_names["emission_color"] = "Emission Color"
	custom_property_names["emission_energy"] = "Emission Energy"
	return custom_property_names
