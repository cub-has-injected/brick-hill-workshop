class_name BrickHillModel
extends BrickHillMeshObject
tool 


export (String) var model_name:String setget set_model_name


var mesh_instance:MeshInstance
var shader_material:ShaderMaterial


func set_model_name(new_model_name:String)->void :
	var scope = Profiler.scope(self, "set_model_name")

	if model_name != new_model_name:
		model_name = new_model_name
		if is_inside_tree():
			update_mesh()


func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Model"


func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh")

	.update_mesh()

	if PRINT:
		print_debug("%s update mesh" % [get_name()])
	mesh_instance.set_mesh(null)
	collision_shape.set_shape(null)

	var mesh = ModelManager.get_model_mesh(model_name)
	if not mesh:
		return 

	var current_mesh = mesh_instance.get_mesh()
	BrickHillUtil.disconnect_checked(current_mesh, "build_complete", self, "update_mesh_position")

	mesh_instance.set_mesh(mesh)
	BrickHillUtil.connect_checked(mesh, "build_complete", self, "update_mesh_position")

	collision_shape.set_shape(ModelManager.get_model_shape(model_name))


func update_mesh_position()->void :
	var scope = Profiler.scope(self, "update_mesh_position")

	if PRINT:
		print_debug("%s update mesh position" % [get_name()])

	var mesh = mesh_instance.get_mesh()
	if mesh:
		mesh_instance.transform.origin = - mesh.center
		rigid_body.transform.origin = mesh.center


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	._enter_tree()

	
	for child in rigid_body.get_children():
		if child.has_meta("model_child"):
			if child != mesh_instance:
				remove_child(child)
				child.queue_free()

	shader_material = ShaderMaterial.new()
	shader_material.set_shader(BrickHillResources.SHADERS.model_opaque)

	mesh_instance = MeshInstance.new()
	mesh_instance.set_material_override(shader_material)
	mesh_instance.set_meta("model_child", true)
	rigid_body.add_child(mesh_instance)

func initial_update()->void :
	var scope = Profiler.scope(self, "initial_update")

	.initial_update()
	update_mesh()
	update_mesh_position()

func get_materials()->Array:
	var scope = Profiler.scope(self, "get_materials")

	.get_materials()

	return [shader_material]

func get_property_data()->Array:
	return .get_property_data() + [
		PropertyUtil.InspectorCategory.new("Data", [
			PropertyUtil.InspectorProperty.new("model_name", TYPE_STRING)
		])
	]

func get_tree_icon(highlight:bool = false)->Texture:
	return BrickHillResources.ICONS.tree_highlight_special if highlight else BrickHillResources.ICONS.tree_special

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Mesh"]["Model"] = [
		"model_name"
	]

	return categories
