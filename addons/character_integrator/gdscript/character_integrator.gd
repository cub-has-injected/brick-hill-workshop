class_name CharacterIntegrator
extends Resource
tool 

export (CylinderShape) var main_shape:CylinderShape
export (CylinderShape) var ground_shape:CylinderShape
export (int, LAYERS_3D_PHYSICS) var collision_mask: = 1
export (float) var gravity_factor: = 6.75
export (float) var force_ground_acceleration: = 200.0
export (float) var force_air_acceleration: = 40.0
export (float) var force_ground_deceleration: = 200.0
export (float) var force_air_deceleration: = 40.0
export (float) var impulse_jump: = 20.0
export (float) var force_jump: = 10.0
export (float) var soft_velocity_limit: = 12.0
export (float) var hard_velocity_limit: = 100.0
export (float) var floor_normal_dot_limit: = 0.1
export (float) var min_step_depth: = 0.5

export (float) var step_down_range: = 1.5
export (float) var min_step_down: = 0.05
export (float) var step_up_range: = 1.5
export (float) var step_offset_lerp_factor: = 1.0
export (float) var min_step_offset_lerp_speed: = 10.0

var target_basis: = Basis.IDENTITY
var wish_vector: = Vector3.ZERO
var jump_buffered: = false
var jump_held: = false
var exclude: = []

var ground_basis: = Basis.IDENTITY
var ground_mode:int = - 1
var step_up_cast_mover:CastMover = null
var step_down_cast_mover:CastMover = null
var step_offset: = Vector3.ZERO
var stepped_down: = false
var stepped_up: = false

var linear_velocity: = Vector3.ZERO
var lateral_velocity: = Vector3.ZERO
var ground_velocity: = Vector3.ZERO
var grounded: = false
var prev_grounded: = false

func get_global_wish_vector()->Vector3:
	var scope = Profiler.scope(self, "get_global_wish_vector", [])

	return ground_basis.xform(wish_vector)

func get_global_lateral_velocity()->Vector3:
	var scope = Profiler.scope(self, "get_global_lateral_velocity", [])

	return (ground_basis.x * lateral_velocity.x) + (ground_basis.z * lateral_velocity.z)

func _init()->void :
	if get_name().empty():
		set_name("Player Integrator")

	step_up_cast_mover = CastMover.new()
	step_down_cast_mover = CastMover.new()

func draw_debug(geo:ImmediateGeometry, origin:Vector3)->void :
	var scope = Profiler.scope(self, "draw_debug", [geo, origin])

	
	WireLine.draw_relative(geo, origin + Vector3.UP * 2.0, get_global_wish_vector(), Color.red)

	
	WireLine.draw_relative(geo, origin + Vector3.DOWN * 3.0, linear_velocity, Color.orange)
	WireLine.draw_relative(geo, origin + Vector3.DOWN * 3.0, get_global_lateral_velocity(), Color.yellow)
	WireLine.draw_relative(geo, origin + Vector3.DOWN * 3.0, ground_velocity, Color.green)

	
	WireTransform.draw(geo, Transform(ground_basis.scaled(Vector3.ONE * 0.5), origin + Vector3.DOWN * 2.0))

	
	if step_down_cast_mover.results:
		step_down_cast_mover.results.draw_debug(geo)

	if step_up_cast_mover.results:
		step_up_cast_mover.results.draw_debug(geo)

func process(delta:float, linear_velocity:Vector3)->void :
	var scope = Profiler.scope(self, "process", [delta, linear_velocity])

	if step_offset.length() > 0.0:
		step_offset -= step_offset.normalized() * min(step_offset.length(), delta * max(linear_velocity.length() * step_offset_lerp_factor, min_step_offset_lerp_speed))

func integrate_forces(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "integrate_forces", [state])

	update_linear_velocity(state)

	update_grounded(state)
	update_ground_basis(state)
	update_ground_velocity(state)

	apply_ground_velocity(state)

	update_lateral_velocity(state)

	stepped_down = try_step_down(state)

	apply_gravity(state)

	if not stepped_down:
		stepped_up = try_step_up(state)
	else :
		stepped_up = false

	apply_acceleration(state)
	apply_jump(state)
	apply_hard_velocity_limit(state)

	update_prev_grounded()

func update_grounded(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "update_grounded", [state])

	var ground_contact_indices = get_ground_contact_indices(state)
	grounded = ground_contact_indices.size() > 0

func update_prev_grounded()->void :
	var scope = Profiler.scope(self, "update_prev_grounded", [])

	prev_grounded = grounded

func apply_ground_velocity(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "apply_ground_velocity", [state])

	state.transform.origin += ground_velocity * state.step

func update_linear_velocity(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "update_linear_velocity", [state])

	linear_velocity = state.linear_velocity

func update_lateral_velocity(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "update_lateral_velocity", [state])

	lateral_velocity = Vector3(ground_basis.x.dot(state.linear_velocity), 0.0, ground_basis.z.dot(state.linear_velocity))

func try_step_down(state:PhysicsDirectBodyState)->bool:
	var scope = Profiler.scope(self, "try_step_down", [state])

	
	step_down_cast_mover.setup(
			state.get_space_state(), 
			state.transform, 
			main_shape, 
			collision_mask, 
			exclude
		)

	if grounded and prev_grounded and lateral_velocity.length() > 0.001 and ground_velocity.length() < 0.001:
		step_down_cast_mover.move(
			CastMover.Motion.new(get_global_lateral_velocity() * state.step, CastMover.Motion.Mode.Continuous)
		).move(
			CastMover.Motion.new( - ground_basis.y * step_down_range, CastMover.Motion.Mode.Obstructed)
		)

		if step_down_cast_mover.success():
			if step_down_cast_mover.results.results.back().safe_move_dist > min_step_down:
				var step_down_delta = state.transform.origin - step_down_cast_mover.results.to.origin
				stepped_down = true
				step_offset += step_down_delta
				state.transform = step_down_cast_mover.results.to
				return true

	return false

func try_step_up(state:PhysicsDirectBodyState)->bool:
	var scope = Profiler.scope(self, "try_step_up", [state])

	
	var wall_contact_indices = get_wall_contact_indices(state)
	var touching_wall = wall_contact_indices.size() > 0
	var wall_normal = average_contact_normals(state, wall_contact_indices)

	
	step_up_cast_mover.setup(
		state.get_space_state(), 
		state.transform, 
		main_shape, 
		collision_mask, 
		exclude
	)

	var pressing_against_wall = touching_wall and get_global_wish_vector().dot(wall_normal) < 0.0

	if (grounded and prev_grounded) and ground_velocity.length() < 0.001 and (lateral_velocity.length() > 0.001 or pressing_against_wall):
		var vel = get_global_lateral_velocity() * state.step
		if pressing_against_wall:
			vel -= wall_normal * 0.05

		step_up_cast_mover.move(
			CastMover.Motion.new(vel, CastMover.Motion.Mode.Continuous)
		)

		if step_up_cast_mover.results.results[0].collision_dist < 1.0:
			wall_normal = step_up_cast_mover.results.rest_info.normal

			step_up_cast_mover.move(
				CastMover.Motion.new(ground_basis.y * step_up_range, CastMover.Motion.Mode.Unobstructed)
			)

			if step_up_cast_mover.success():
				var velocity_result = step_up_cast_mover.results.results[0].safe_move_dist
				var motion = wall_normal.normalized() * wall_normal.dot(vel * (1.0 - velocity_result))

				step_up_cast_mover.move(
					CastMover.Motion.new(motion, CastMover.Motion.Mode.Unobstructed, 1.0 - motion.length())
				).move(
					CastMover.Motion.new( - ground_basis.y * step_up_range, CastMover.Motion.Mode.Obstructed)
				)

				if step_up_cast_mover.success():
					var rest_info = step_up_cast_mover.results.rest_info
					if not rest_info.empty() and rest_info.normal.dot(Vector3.UP) > floor_normal_dot_limit:
						var step_up_delta = state.transform.origin - step_up_cast_mover.results.to.origin
						step_offset += step_up_delta
						state.transform = step_up_cast_mover.results.to
						return true
	return false


func get_ground_contact_indices(state:PhysicsDirectBodyState)->Array:
	var scope = Profiler.scope(self, "get_ground_contact_indices", [state])

	var ground_contact_indices: = []
	for i in range(0, state.get_contact_count()):
		var contact_normal = state.get_contact_local_normal(i)
		if contact_normal.dot(Vector3.UP) >= floor_normal_dot_limit:
			ground_contact_indices.append(i)
	return ground_contact_indices


func get_wall_contact_indices(state:PhysicsDirectBodyState)->Array:
	var scope = Profiler.scope(self, "get_wall_contact_indices", [state])

	var wall_contact_indices: = []
	for i in range(0, state.get_contact_count()):
		var contact_normal = state.get_contact_local_normal(i)
		if contact_normal.dot(Vector3.UP) < floor_normal_dot_limit:
			wall_contact_indices.append(i)
	return wall_contact_indices


func average_contact_normals(state:PhysicsDirectBodyState, ground_contact_indices:Array)->Vector3:
	var scope = Profiler.scope(self, "average_contact_normals", [state, ground_contact_indices])

	var ground_normal = Vector3.ZERO
	var first = true
	for i in ground_contact_indices:
		assert (i < state.get_contact_count())
		var normal = state.get_contact_local_normal(i)
		if first:
			ground_normal = normal
			first = false
		else :
			ground_normal += normal

	ground_normal = ground_normal.normalized()
	return ground_normal

func get_ground_rest_info(state:PhysicsDirectBodyState, offset_fac:float = 1.0)->Dictionary:
	var scope = Profiler.scope(self, "get_ground_rest_info", [state, offset_fac])

	var ground_query = PhysicsShapeQueryParameters.new()
	ground_query.set_shape(ground_shape)
	ground_query.transform = state.transform
	ground_query.transform.origin -= state.transform.basis.y * main_shape.height * 0.5
	ground_query.transform.origin -= state.transform.basis.y * ground_shape.height * 0.5 * offset_fac
	ground_query.exclude = exclude
	ground_query.collision_mask = collision_mask

	return state.get_space_state().get_rest_info(ground_query)

func update_ground_basis(state:PhysicsDirectBodyState):
	var scope = Profiler.scope(self, "update_ground_basis", [state])

	ground_basis = target_basis

	var rest_result = get_ground_rest_info(state)

	if not rest_result.empty():
		var ground_normal = rest_result.normal
		if ground_normal.dot(Vector3.UP) > floor_normal_dot_limit:
			var c = ground_basis.y.cross(ground_normal)
			var d = ground_basis.y.dot(ground_normal)
			if abs(c.x) < 0.01:
				c.x = 0
			if abs(c.y) < 0.01:
				c.y = 0
			if abs(c.z) < 0.01:
				c.z = 0
			if c != Vector3.ZERO:
				var axis = c.normalized()
				var angle = atan2(c.length(), d)
				ground_basis = ground_basis.rotated(axis, angle)

func update_ground_velocity(state:PhysicsDirectBodyState):
	var scope = Profiler.scope(self, "update_ground_velocity", [state])

	ground_velocity = Vector3.ZERO
	ground_mode = - 1

	var rest_result = get_ground_rest_info(state, 0.0)

	if not rest_result.empty():
		var ground_collider = instance_from_id(rest_result.collider_id)
		if ground_collider is RigidBody:
			var trx = ground_collider.global_transform
			ground_velocity += ground_collider.linear_velocity
			ground_velocity -= ground_basis.y * ground_basis.y.dot(ground_velocity)

			var angular_velocity = ground_collider.angular_velocity * state.step

			var local_from: = Vector3.ZERO
			if angular_velocity.x != 0 or angular_velocity.z != 0:
				local_from = rest_result.point - trx.origin
			else :
				local_from = state.transform.origin - trx.origin

			var local_to = local_from
			local_to = local_to.rotated(Vector3.RIGHT, angular_velocity.x)
			local_to = local_to.rotated(Vector3.UP, angular_velocity.y)
			local_to = local_to.rotated(Vector3.BACK, angular_velocity.z)
			var delta = local_to - local_from
			delta -= ground_basis.y * ground_basis.y.dot(delta)
			ground_velocity += delta / state.step

			ground_mode = ground_collider.mode

func apply_gravity(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "apply_gravity", [state])

	if grounded and prev_grounded and ground_mode == RigidBody.MODE_RIGID:
		return 

	state.add_central_force(state.total_gravity * gravity_factor)

func apply_acceleration(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "apply_acceleration", [state])

	
	
	var global_wish_vector = get_global_wish_vector()
	var vdw = get_global_lateral_velocity().dot(global_wish_vector)
	if vdw != 0 or lateral_velocity.length() == 0:
		var force: = 0.0
		if grounded and prev_grounded:
			force = force_ground_acceleration
		else :
			force = force_air_acceleration
		var acc = global_wish_vector * force
		state.add_central_force(acc)

	
	if (grounded and prev_grounded and vdw == 0) or lateral_velocity.length() > soft_velocity_limit:
		var lv_norm = ground_basis.xform(lateral_velocity.normalized())
		var lv_mag = lateral_velocity.length()
		var force = 0.0
		if grounded and prev_grounded:
			force = force_ground_deceleration
		else :
			force = force_air_deceleration
		state.add_central_force( - lv_norm * min(force, lv_mag / state.step))

func apply_jump(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "apply_jump", [state])

	if jump_buffered:
		if grounded and prev_grounded:
			state.linear_velocity += ground_velocity
			state.apply_central_impulse(Vector3.UP * impulse_jump)
			grounded = false
			jump_buffered = false

	if jump_held:
		if not grounded and not prev_grounded and state.linear_velocity.dot(Vector3.UP) >= 0.0:
			state.add_central_force(Vector3.UP * force_jump)

func apply_hard_velocity_limit(state:PhysicsDirectBodyState)->void :
	var scope = Profiler.scope(self, "apply_hard_velocity_limit", [state])

	if state.linear_velocity.length() > hard_velocity_limit:
		state.linear_velocity = state.linear_velocity.normalized() * hard_velocity_limit
