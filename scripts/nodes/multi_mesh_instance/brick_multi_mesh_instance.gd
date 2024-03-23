class_name BrickMultiMeshInstance
extends MultiMeshInstance
tool 

const MAX_BRICKS: = 10240

const PRINT: = false

export (ModelManager.BrickMeshType) var mesh_type = ModelManager.BrickMeshType.CUBE setget set_mesh_type

var multi_mesh:MultiMesh

var instances:Array

func set_mesh_type(new_mesh_type:int)->void :
	var scope = Profiler.scope(self, "set_mesh_type", [new_mesh_type])

	if mesh_type != new_mesh_type:
		mesh_type = new_mesh_type
		if is_inside_tree():
			mesh_type_changed()

func mesh_type_changed()->void :
	var scope = Profiler.scope(self, "mesh_type_changed", [])

	update_mesh()

func update_mesh()->void :
	var scope = Profiler.scope(self, "update_mesh", [])

	multi_mesh.set_mesh(ModelManager.get_brick_mesh(mesh_type))

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	instances = []

	set_visible(false)

func _enter_tree():
	var scope = Profiler.scope(self, "_enter_tree", [])

	multi_mesh = MultiMesh.new()
	multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
	multi_mesh.color_format = MultiMesh.COLOR_FLOAT
	multi_mesh.custom_data_format = MultiMesh.CUSTOM_DATA_FLOAT
	multi_mesh.instance_count = MAX_BRICKS
	multi_mesh.visible_instance_count = 0
	set_multimesh(multi_mesh)

	mesh_type_changed()

func add_instance(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "add_instance", [instance])

	if not instance:
		return 

	instances.append(instance)
	multi_mesh.visible_instance_count += 1

	if PRINT:
		print_debug("%s instance added: %s. visible instance count: %s" % [get_name(), instance, multi_mesh.visible_instance_count])

	update_instance(instance)
	set_visible(true)

func remove_instance(instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "remove_instance", [instance])

	
	var idx = instances.find(instance)
	if idx < 0 or idx >= instances.size():
		return 

	var popped_instance = instances.pop_back()
	if instance != popped_instance:
		instances[idx] = popped_instance

	multi_mesh.visible_instance_count -= 1

	if PRINT:
		print_debug("%s instance removed: %s. visible instance count: %s" % [get_name(), instance, multi_mesh.visible_instance_count])

	if multi_mesh.visible_instance_count > 0:
		update_instance(popped_instance)
	else :
		set_visible(false)

func get_multi_mesh_index(brick_instance:BrickInstance)->int:
	var scope = Profiler.scope(self, "get_multi_mesh_instance", [brick_instance])

	return instances.find(brick_instance)

func update_instance(brick_instance:BrickInstance)->void :
	var scope = Profiler.scope(self, "update_instance", [brick_instance])

	var idx = get_multi_mesh_index(brick_instance)
	var multi_mesh_instance = get_instance_by_idx(idx)
	update_instance_transform(idx, multi_mesh_instance)
	update_instance_color_data(idx, multi_mesh_instance)
	update_instance_custom_data(idx, multi_mesh_instance)

func update_instance_transform(idx:int, instance)->void :
	var scope = Profiler.scope(self, "update_instance_transform", [instance])

	if PRINT:
		print_debug("%s instance transform changed: %s" % [get_name(), instance])

	if instance and instance.is_inside_tree():
		multi_mesh.set_instance_transform(idx, instance.global_transform)

func update_instance_color_data(idx:int, instance)->void :
	var scope = Profiler.scope(self, "update_instance_color_data", [instance])

	if PRINT:
		print_debug("%s instance color data changed: %s" % [get_name(), instance])

	if instance:
		multi_mesh.set_instance_color(idx, Color(instance.roughness, instance.metallic, instance.opacity, instance.refraction))

func update_instance_custom_data(idx:int, instance)->void :
	var scope = Profiler.scope(self, "update_instance_custom_data", [instance])

	if PRINT:
		print_debug("%s instance custom data changed: %s" % [get_name(), instance])

	if instance:
		var texture_size = Vector2(512, 512)
		var unit_size = 64.0
		var offset = instance.uv_offset
		offset /= unit_size
		var uv_offset = fmod(offset.x, texture_size.x / unit_size) + (offset.y * texture_size.x)
		multi_mesh.set_instance_custom_data(idx, Color(instance.mesh_type, instance.material_idx, instance.palette_key, uv_offset))

func get_instance_by_idx(idx:int):
	var scope = Profiler.scope(self, "get_instance_by_idx", [idx])

	if idx < 0 or idx >= instances.size():
		return null

	var instance = instances[idx]

	if not instance:
		remove_instance(instance)
		return null

	return instance
