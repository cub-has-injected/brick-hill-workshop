class_name BrickHillGroup
extends BrickHillPhysicsObject
tool 

export (Vector3) var origin: = Vector3.ZERO setget set_origin

var aabb_material:SpatialMaterial
var immediate_geometry:ImmediateGeometry

var is_hovered: = false
var is_selected: = false
var active = false setget set_active
var aabb_active_opacity = 0.6
var aabb_inactive_opacity = 0.2
var margin = 0.0

var _cached_aabb:AABB
var _cached_basis:Basis
var _prev_flip:Array

func set_active(new_active:bool)->void :
	var scope = Profiler.scope(self, "set_active", [new_active])

	if active != new_active:
		active = new_active
		aabb_material.albedo_color = get_aabb_color()
		aabb_material.albedo_color.a = 1.0 if active else 0.5
		immediate_geometry.visible = active
		update_process()

func set_origin(new_origin:Vector3)->void :
	var scope = Profiler.scope(self, "set_origin", [new_origin])

	if origin != new_origin:
		origin = new_origin
		if is_inside_tree():
			update_origin()

func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Group"

func get_aabb_color()->Color:
	var scope = Profiler.scope(self, "get_aabb_color")

	return Color("#00a9fe")

func hovered()->void :
	var scope = Profiler.scope(self, "hovered")

	is_hovered = true
	immediate_geometry.visible = true
	update_process()

func unhovered()->void :
	var scope = Profiler.scope(self, "unhovered")

	is_hovered = false
	immediate_geometry.visible = active or is_selected
	update_process()

func selected()->void :
	var scope = Profiler.scope(self, "selected")

	is_selected = true
	immediate_geometry.visible = true
	update_process()

func unselected()->void :
	var scope = Profiler.scope(self, "unselected")

	is_selected = false
	immediate_geometry.visible = active
	update_process()

func get_shapes()->InterfaceShapes.Shapes:
	var scope = Profiler.scope(self, "get_shapes")

	var shapes = InterfaceShapes.Shapes.new()

	for child in get_children():
		if InterfaceShapes.is_implementor(child):
			var child_trx = child.transform
			var child_shapes = InterfaceShapes.get_shapes(child)
			var child_shape_dict = child_shapes.get_shapes()
			for shape_trx in child_shape_dict:
				for shape in child_shape_dict[shape_trx]:
					shapes.add_shape(child_trx * shape_trx, shape)

	return shapes

func get_collision_layer()->int:
	var scope = Profiler.scope(self, "get_collision_layer")

	var collision_layer = 0

	for child in get_children():
		if InterfaceCollisionLayer.is_implementor(child):
			collision_layer |= InterfaceCollisionLayer.get_collision_layer(child)

	return collision_layer

func set_collision_layer(new_collision_layer:int)->void :
	var scope = Profiler.scope(self, "set_collision_layer", [new_collision_layer])

	for child in get_children():
		if InterfaceCollisionLayer.is_implementor(child):
			InterfaceCollisionLayer.set_collision_layer(child, new_collision_layer)

func get_collision_mask()->int:
	var scope = Profiler.scope(self, "get_collision_mask")

	var collision_mask = 0

	for child in get_children():
		if InterfaceCollisionMask.is_implementor(child):
			collision_mask |= InterfaceCollisionMask.get_collision_mask(child)

	return collision_mask

func set_collision_mask(new_collision_mask:int)->void :
	var scope = Profiler.scope(self, "set_collision_mask", [new_collision_mask])

	for child in get_children():
		if InterfaceCollisionMask.is_implementor(child):
			InterfaceCollisionMask.set_collision_mask(child, new_collision_mask)

func initial_update()->void :
	var scope = Profiler.scope(self, "initial_update")

	.initial_update()
	update_origin()

func _init()->void :
	var scope = Profiler.scope(self, "_init")

	._init()

	_prev_flip = flip.duplicate()

func _ready()->void :
	var scope = Profiler.scope(self, "_ready")

	aabb_material = SpatialMaterial.new()
	aabb_material.albedo_color = get_aabb_color()
	aabb_material.albedo_color.a = 0.5
	aabb_material.flags_transparent = true
	aabb_material.flags_unshaded = true
	aabb_material.render_priority = 1

	immediate_geometry = ImmediateGeometry.new()
	immediate_geometry.material_override = aabb_material
	immediate_geometry.visible = false
	add_child(immediate_geometry)

	_ready_group()

func _ready_group()->void :
	var scope = Profiler.scope(self, "_ready_group")

	remove_child(rigid_body)

func get_tree_icon(highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon", [highlight])

	return BrickHillResources.ICONS.tree_highlight_group if highlight else BrickHillResources.ICONS.tree_group

func get_local_center()->Vector3:
	var scope = Profiler.scope(self, "get_local_center")

	var bounds = get_bounds()
	return bounds.position + bounds.size * 0.5

func get_bounds()->AABB:
	var scope = Profiler.scope(self, "get_bounds")

	var aabb = AABB()

	for child in get_children():
		if child is BrickHillObject:
			var trx = child.transform
			trx.basis = trx.basis.orthonormalized()
			var bounds = trx.xform(child.get_bounds())
			if aabb.has_no_area():
				aabb = bounds
			else :
				aabb = aabb.merge(bounds)

	return aabb

func get_size()->Vector3:
	var scope = Profiler.scope(self, "get_size")

	return get_bounds().size

func size_changed()->void :
	var scope = Profiler.scope(self, "size_changed")

	pass

func flip_changed()->void :
	var scope = Profiler.scope(self, "flip_changed")

	.flip_changed()

	var x = flip[0] != _prev_flip[0]
	var y = flip[1] != _prev_flip[1]
	var z = flip[2] != _prev_flip[2]
	_prev_flip = flip.duplicate()

	for child in get_children():
		if x:
			child.transform.origin.x *= - 1
		if y:
			child.transform.origin.y *= - 1
		if z:
			child.transform.origin.z *= - 1

		if child.has_method("toggle_flip"):
			child.toggle_flip(x, y, z)

func update_process()->void :
	set_process(is_hovered or is_selected or active)

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])
	update_aabb()
	update_process()

func update_aabb()->void :
	var scope = Profiler.scope(self, "update_aabb")

	var aabb = AABB()
	for child in get_children():
		if child is BrickHillPhysicsObject:
			var trx = child.transform
			trx.basis = trx.basis.orthonormalized()
			var bounds = trx.xform(child.get_bounds())
			if aabb.has_no_area():
				aabb = bounds
			else :
				aabb = aabb.merge(bounds)

	if aabb != _cached_aabb or global_transform.basis != _cached_basis:
		var visual_aabb = aabb
		if margin > 0:
			visual_aabb.grow(margin)

		var visual_points: = []
		for i in range(0, 8):
			var visual_endpoint = visual_aabb.get_endpoint(i)
			visual_points.append(global_transform.basis.orthonormalized().xform(visual_endpoint))

		immediate_geometry.clear()
		immediate_geometry.begin(Mesh.PRIMITIVE_LINES)

		
		immediate_geometry.add_vertex(visual_points[2])
		immediate_geometry.add_vertex(visual_points[6])

		immediate_geometry.add_vertex(visual_points[3])
		immediate_geometry.add_vertex(visual_points[7])

		immediate_geometry.add_vertex(visual_points[2])
		immediate_geometry.add_vertex(visual_points[3])

		immediate_geometry.add_vertex(visual_points[6])
		immediate_geometry.add_vertex(visual_points[7])

		
		immediate_geometry.add_vertex(visual_points[0])
		immediate_geometry.add_vertex(visual_points[4])

		immediate_geometry.add_vertex(visual_points[1])
		immediate_geometry.add_vertex(visual_points[5])

		immediate_geometry.add_vertex(visual_points[0])
		immediate_geometry.add_vertex(visual_points[1])

		immediate_geometry.add_vertex(visual_points[4])
		immediate_geometry.add_vertex(visual_points[5])

		
		immediate_geometry.add_vertex(visual_points[0])
		immediate_geometry.add_vertex(visual_points[2])

		immediate_geometry.add_vertex(visual_points[1])
		immediate_geometry.add_vertex(visual_points[3])

		immediate_geometry.add_vertex(visual_points[4])
		immediate_geometry.add_vertex(visual_points[6])

		immediate_geometry.add_vertex(visual_points[5])
		immediate_geometry.add_vertex(visual_points[7])

		immediate_geometry.end()

		immediate_geometry.global_transform.basis = Basis.IDENTITY

		_cached_aabb = aabb
		_cached_basis = global_transform.basis

func update_origin()->void :
	var scope = Profiler.scope(self, "update_origin")

	var local_center = InterfaceLocalCenter.get_local_center(self)
	if local_center != origin:
		var delta = local_center - origin
		transform.origin += delta
		for child in get_children():
			if not child is Spatial:
				continue

			if child == immediate_geometry:
				continue

			child.transform.origin -= delta

	_cached_aabb = AABB(Vector3.ZERO, Vector3.ZERO)

func unfreeze()->void :
	var scope = Profiler.scope(self, "get_rigid_body")

	.unfreeze()
	set_active(false)

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Object"]["Transform"].append("origin")

	return categories
