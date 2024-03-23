class_name CompositeRigidBodyBase
extends RigidBody
tool 

var _cached_rigid_bodies:Array

func compose_shape_owners(rigid_bodies)->void :
	var scope = Profiler.scope(self, "compose_shape_owners", [rigid_bodies])

	for child_rigid_body in rigid_bodies:
		_cached_rigid_bodies.append(weakref(child_rigid_body))
		add_collision_exception_with(child_rigid_body)

		var body_trx = global_transform.inverse() * child_rigid_body.global_transform
		var shape_owners = child_rigid_body.get_shape_owners()

		for child_owner in shape_owners:
			var shape_trx = child_rigid_body.shape_owner_get_transform(child_owner)
			var shape_count = child_rigid_body.shape_owner_get_shape_count(child_owner)

			for shape_idx in range(0, shape_count):
				var child_shape_owner = create_shape_owner(self)
				shape_owner_set_transform(child_shape_owner, body_trx * shape_trx)

				var child_shape = child_rigid_body.shape_owner_get_shape(child_owner, shape_idx)
				shape_owner_add_shape(child_shape_owner, child_shape)

func disable_child_shapes()->void :
	var scope = Profiler.scope(self, "disable_child_shapes", [])

	for child_rigid_body_weakref in _cached_rigid_bodies:
		var child_rigid_body = child_rigid_body_weakref.get_ref()
		if child_rigid_body:
			var shape_owners = child_rigid_body.get_shape_owners()
			for child_owner in shape_owners:
				child_rigid_body.shape_owner_set_disabled(child_owner, true)

func enable_child_shapes()->void :
	var scope = Profiler.scope(self, "enable_child_shapes", [])

	for child_rigid_body_weakref in _cached_rigid_bodies:
		var child_rigid_body = child_rigid_body_weakref.get_ref()
		if child_rigid_body:
			var shape_owners = child_rigid_body.get_shape_owners()
			for child_owner in shape_owners:
				child_rigid_body.shape_owner_set_disabled(child_owner, false)


func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	for owner in get_shape_owners():
		remove_shape_owner(owner)

	for rigid_body_weakref in _cached_rigid_bodies:
		var rigid_body = rigid_body_weakref.get_ref()
		if rigid_body:
			remove_collision_exception_with(rigid_body)

	_cached_rigid_bodies.clear()

func test_collision(state:PhysicsDirectBodyState, transform:Transform)->Array:
	var scope = Profiler.scope(self, "test_collision", [state, transform])

	var results: = []

	var query = PhysicsShapeQueryParameters.new()
	query.collision_mask = collision_mask
	query.exclude = [self]
	query.margin = - 0.001

	var shape_owners = get_shape_owners()
	for owner in shape_owners:
		var shape_count = shape_owner_get_shape_count(owner)
		query.transform = transform * shape_owner_get_transform(owner)

		for shape_idx in range(0, shape_count):
			query.set_shape(shape_owner_get_shape(owner, shape_idx))
			results += state.get_space_state().intersect_shape(query)

	return results
