class_name BrickHillPhysicsObject
extends BrickHillObject
tool 

const MAX_FRICTION: = 5.0


export (float, 0.01, 10.0, 0.01) var mass_per_stud: = 0.2 setget set_mass_per_stud
export (float, 0.01, 10.0, 0.01) var gravity_scale: = 3.7 setget set_gravity_scale

export (float, 0, 5, 0.1) var friction: = 3.0 setget set_friction
export (bool) var rough: = true setget set_rough

export (float, 0, 1, 0.01) var bounce: = 0.1 setget set_bounce
export (bool) var absorbent: = false setget set_absorbent


var collision_type = BrickHillUtil.CollisionType.CONVEX setget set_collision_type
var physics_material:PhysicsMaterial
var rigid_body:RigidBody
var collision_shape:CollisionShape


func set_mass_per_stud(new_mass_per_stud:float)->void :
	var scope = Profiler.scope(self, "set_mass_per_stud", [new_mass_per_stud])

	if mass_per_stud != new_mass_per_stud:
		mass_per_stud = new_mass_per_stud
		if is_inside_tree():
			mass_per_stud_changed()

func set_gravity_scale(new_gravity_scale:float)->void :
	var scope = Profiler.scope(self, "set_gravity_scale", [new_gravity_scale])

	if gravity_scale != new_gravity_scale:
		gravity_scale = new_gravity_scale
		if is_inside_tree():
			gravity_scale_changed()

func set_friction(new_friction:float)->void :
	var scope = Profiler.scope(self, "set_friction", [new_friction])

	if friction != new_friction:
		friction = new_friction
		if is_inside_tree():
			friction_changed()

func set_rough(new_rough:bool)->void :
	var scope = Profiler.scope(self, "set_rough", [new_rough])

	if rough != new_rough:
		rough = new_rough
		if is_inside_tree():
			rough_changed()

func set_bounce(new_bounce:float)->void :
	var scope = Profiler.scope(self, "set_bounce", [new_bounce])

	if bounce != new_bounce:
		bounce = new_bounce
		if is_inside_tree():
			bounce_changed()

func set_absorbent(new_absorbent:bool)->void :
	var scope = Profiler.scope(self, "set_absorbent", [new_absorbent])

	if absorbent != new_absorbent:
		absorbent = new_absorbent
		if is_inside_tree():
			absorbent_changed()

func set_collision_type(new_collision_type:int)->void :
	var scope = Profiler.scope(self, "set_collision_type", [new_collision_type])

	if PRINT:
		print_debug("%s set collision type to %s" % [get_name(), new_collision_type])

	if collision_type != new_collision_type:
		collision_type = new_collision_type
		if is_inside_tree():
			update_collision()


func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "PhysicsObject"

func get_rigid_body()->RigidBody:
	var scope = Profiler.scope(self, "get_rigid_body")

	if PRINT:
		print_debug("%s get rigid body" % [get_name()])

	return rigid_body

func get_shapes()->InterfaceShapes.Shapes:
	var scope = Profiler.scope(self, "get_shapes")

	var shapes = InterfaceShapes.Shapes.new()
	shapes.add_shape(collision_shape.transform, collision_shape.shape)
	return shapes

func get_collision_layer()->int:
	var scope = Profiler.scope(self, "get_collision_layer")

	return rigid_body.collision_layer

func set_collision_layer(new_collision_layers:int)->void :
	var scope = Profiler.scope(self, "set_collision_layer", [new_collision_layers])

	rigid_body.collision_layer = new_collision_layers

func get_collision_mask()->int:
	var scope = Profiler.scope(self, "get_collision_mask")

	return rigid_body.collision_mask

func set_collision_mask(new_collision_mask:int)->void :
	var scope = Profiler.scope(self, "set_collision_mask", [new_collision_mask])

	rigid_body.collision_mask = new_collision_mask

func is_ray_pickable()->bool:
	var scope = Profiler.scope(self, "is_ray_pickable")

	return get_rigid_body().is_ray_pickable()

func set_ray_pickable(new_ray_pickable:bool)->void :
	var scope = Profiler.scope(self, "set_ray_pickable", [new_ray_pickable])

	get_rigid_body().set_ray_pickable(new_ray_pickable)


func mass_per_stud_changed()->void :
	var scope = Profiler.scope(self, "mass_per_stud_changed")

	mass_changed()

func gravity_scale_changed()->void :
	var scope = Profiler.scope(self, "gravity_scale_changed")

	rigid_body.gravity_scale = gravity_scale

func friction_changed()->void :
	var scope = Profiler.scope(self, "friction_changed")

	physics_material.friction = friction / MAX_FRICTION

func rough_changed()->void :
	var scope = Profiler.scope(self, "rough_changed")

	physics_material.rough = rough

func bounce_changed()->void :
	var scope = Profiler.scope(self, "bounce_changed")

	physics_material.bounce = bounce

func absorbent_changed()->void :
	var scope = Profiler.scope(self, "absorbent_changed")

	physics_material.absorbent = absorbent

func size_changed()->void :
	var scope = Profiler.scope(self, "size_changed")

	update_collision_shape()
	mass_changed()

func flip_changed()->void :
	var scope = Profiler.scope(self, "flip_changed")

	update_collision_shape()

func update_collision_shape()->void :
	var scope = Profiler.scope(self, "update_collision_shape")

	collision_shape.scale = size

	if flip[0]:
		collision_shape.scale.x *= - 1

	if flip[1]:
		collision_shape.scale.y *= - 1

	if flip[2]:
		collision_shape.scale.z *= - 1

func mass_changed()->void :
	var scope = Profiler.scope(self, "mass_changed")

	var mass = (size.x + size.y + size.z) * mass_per_stud
	if mass <= 0:
		mass = mass_per_stud
	rigid_body.mass = mass


func _init()->void :
	var scope = Profiler.scope(self, "_init")

	._init()

	if PRINT:
		print_debug("%s init" % [get_name()])

	physics_material = PhysicsMaterial.new()

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	._enter_tree()
	
	for child in get_children():
		if child.has_meta("brick_hill_physics_object_child"):
			remove_child(child)
			child.queue_free()

	rigid_body = create_physics_body()
	rigid_body.name = "RigidBody"
	rigid_body.physics_material_override = physics_material
	rigid_body.add_to_group("pickable")
	rigid_body.set_meta("brick_hill_physics_object_child", true)

	collision_shape = create_collision_shape()
	collision_shape.name = "CollisionShape"

	rigid_body.add_child(collision_shape)
	add_child(rigid_body)

func create_physics_body()->PhysicsBody:
	var scope = Profiler.scope(self, "create_physics_body")

	var physics_body = RigidBody.new()
	physics_body.connect("sleeping_state_changed", self, "physics_body_sleeping_state_changed")
	return physics_body

func physics_body_sleeping_state_changed()->void :
	var scope = Profiler.scope(self, "physics_body_sleeping_state_changed")

func create_collision_shape()->CollisionShape:
	var scope = Profiler.scope(self, "create_collision_shape")

	return CollisionShape.new()

func set_input_capture_on_drag(new_input_capture_on_drag:bool)->void :
	var scope = Profiler.scope(self, "set_input_capture_on_drag")

	rigid_body.input_capture_on_drag = new_input_capture_on_drag

func initial_update()->void :
	var scope = Profiler.scope(self, "initial_update")

	.initial_update()

	add_to_group("brick_hill_physics_object")

	mass_per_stud_changed()
	gravity_scale_changed()
	friction_changed()
	rough_changed()
	bounce_changed()
	absorbent_changed()

	update_collision()
	update_rigid_body()


func update_rigid_body()->void :
	var scope = Profiler.scope(self, "update_rigid_body")

	if PRINT:
		print_debug("%s update rigid body" % [get_name()])

	var mode = RigidBody.MODE_STATIC

	if not frozen:
		match object_mode:
			BrickHillUtil.ObjectMode.DYNAMIC:
				mode = RigidBody.MODE_RIGID
			BrickHillUtil.ObjectMode.STATIC:
				mode = RigidBody.MODE_STATIC

	get_rigid_body().mode = mode
	get_rigid_body().sleeping = false

func update_collision()->void :
	var scope = Profiler.scope(self, "update_collision")

	if PRINT:
		print_debug("%s update collision" % [get_name()])
	pass

func freeze()->void :
	var scope = Profiler.scope(self, "freeze")

	.freeze()
	update_rigid_body()

func unfreeze()->void :
	var scope = Profiler.scope(self, "unfreeze")

	.unfreeze()
	update_rigid_body()

func get_custom_categories()->Dictionary:
	var categories = .get_custom_categories()
	categories["Physics"] = {
		"Forces":[
			"mass_per_stud", 
			"gravity_scale", 
		], 
		"Friction":[
			"friction", 
			"rough", 
		], 
		"Bounce":[
			"bounce", 
			"absorbent"
		]
	}

	return categories

func get_custom_property_names()->Dictionary:
	var custom_property_names = .get_custom_property_names()
	return custom_property_names

func get_group_properties()->Dictionary:
	return {
		"Friction":"friction", 
		"Bounce":"bounce", 
	}
