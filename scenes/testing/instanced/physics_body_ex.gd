class_name PhysicsBodyEx
extends PhysicsBody

signal stepped()
signal pressed()

signal lateral_motion_absorbed(motion)
signal vertical_motion_absorbed(motion)
signal stepped_up(distance)
signal stepped_down(distance)

const DEBUG: = true





















export (Vector3) var debug_motion: = Vector3.FORWARD
export (float) var max_slope_angle: = 45.0

var _queued_moves: = []
var _frame_history: = []
var _is_on_floor: = false
var _color_head: = 0.0
var _color_step: = 0.6

func set_visible(new_visible:bool)->void :
	.set_visible(new_visible)

	input_ray_pickable = visible

	var debug_draw = get_debug_draw()
	if debug_draw:
		debug_draw.visible = visible

func get_debug_log(lateral:bool, vertical:bool, slide_index:int)->String:
	var frame = _frame_history[ - 1]

	var debug: = get_debug_draw()
	if debug:
		debug.clear()
		debug.begin(Mesh.PRIMITIVE_LINES)

		if lateral:
			if slide_index < frame.lateral.size():
				frame.lateral[slide_index].debug_draw(debug)

		if vertical:
			if slide_index < frame.vertical.size():
				frame.vertical[slide_index].debug_draw(debug)

		debug.end()

	var strings = []
	if lateral:
		if slide_index < frame.lateral.size():
			strings += frame.lateral[slide_index].debug_log

	if vertical:
		if slide_index < frame.vertical.size():
			strings += frame.vertical[slide_index].debug_log

	return PoolStringArray(strings).join("\n")

func get_rest_info(
	transform:Transform, 
	shape:Shape, 
	exclude:Array, 
	collision_mask:int, 
	margin:float, 
	collide_with_bodies:bool, 
	collide_with_areas:bool
)->Dictionary:
	var direct_space_state = get_world().direct_space_state

	var query: = PhysicsShapeQueryParameters.new()
	query.set_shape(shape)
	query.collision_mask = collision_mask
	query.exclude = exclude
	query.margin = margin
	query.transform = transform
	query.collide_with_bodies = collide_with_bodies
	query.collide_with_areas = collide_with_areas

	return direct_space_state.get_rest_info(query)

func debug_intersect_ray(
	frame_data:PhysicsUtil.FrameData, 
	name:String, 
	color:Color, 
	from:Vector3, 
	to:Vector3
)->Dictionary:
	if DEBUG:
		frame_data.add_debug_trace("%s Trace" % [name], from, to, color)
	var result = intersect_ray(from, to)

	if DEBUG:
		if not result.empty():
			frame_data.add_debug_trace_result("%s Trace Result" % [name], result, color)

	return result

func intersect_ray(
	from:Vector3, 
	to:Vector3
)->Dictionary:
	var direct_space_state = get_world().direct_space_state
	return direct_space_state.intersect_ray(from, to, [self], collision_mask, true, false)

func intersect_shape(
	transform:Transform, 
	shape:Shape, 
	exclude:Array, 
	collision_mask:int, 
	margin:float, 
	collide_with_bodies:bool, 
	collide_with_areas:bool
)->Array:
	var direct_space_state = get_world().direct_space_state

	var query: = PhysicsShapeQueryParameters.new()
	query.set_shape(shape)
	query.collision_mask = collision_mask
	query.exclude = exclude
	query.margin = margin
	query.transform = transform
	query.collide_with_bodies = collide_with_bodies
	query.collide_with_areas = collide_with_areas

	return direct_space_state.intersect_shape(query)

func get_shape()->CollisionShape:
	var shape_owners = get_shape_owners()
	for shape_owner in shape_owners:
		var shape_count = shape_owner_get_shape_count(shape_owner)
		for i in range(0, shape_count):
			var shape = shape_owner_get_shape(shape_owner, i)
			return shape
	return null

func _ready()->void :
	reset()

func _physics_process(_delta:float)->void :
	while _queued_moves.size() > 0:
		var motion = _queued_moves.pop_front()

		var lateral_motion = Vector3(motion.x, 0.0, motion.z)
		var vertical_motion = Vector3(0.0, motion.y, 0.0)

		_frame_history.append({"lateral":[], "vertical":[]})

		step_lateral(lateral_motion)
		step_vertical(vertical_motion)

		emit_signal("stepped")

func reset()->void :
	if _frame_history.size() > 0:
		global_transform.origin = _frame_history[0].vertical[0].position

	var initial_frame = PhysicsUtil.FrameData.new()
	initial_frame.position = global_transform.origin

	_frame_history = [
		{"lateral":[initial_frame], "vertical":[initial_frame]}
	]

func queue_move(motion:Vector3)->void :
	_queued_moves.append(motion)

func reset_color()->void :
	_color_head = 0.0

func get_color()->Color:
	var color = Color.from_hsv(_color_head, 1.0, 1.0)
	_color_head = fmod(_color_head + _color_step, 1.0)
	return color

var step_distance = 1.5
var trace_count: = 32
var floor_offset = Vector3.UP * 0.1

var _sort_position: = Vector3.ZERO
func sort_by_distance(lhs:Dictionary, rhs:Dictionary)->bool:
	return (rhs.position - _sort_position).length() > (lhs.position - _sort_position).length()

var _sort_axis: = Vector3.ZERO
func sort_along_axis(lhs:Dictionary, rhs:Dictionary)->bool:
	return rhs.position.dot(_sort_axis) > lhs.position.dot(_sort_axis)

func sort_by_distance_along_axis(lhs:Dictionary, rhs:Dictionary)->bool:
	var lhs_pos = lhs.position - _sort_position
	var rhs_pos = rhs.position - _sort_position
	return abs(rhs_pos.dot(_sort_axis)) < abs(lhs_pos.dot(_sort_axis))

func trace_closest_surface(
	frame_data:PhysicsUtil.FrameData, 
	color:Color, 
	foot_position:Vector3, 
	lateral_motion:Vector3, 
	count:int, 
	abs_motion:bool = false
)->Dictionary:
	assert (lateral_motion.y == 0.0)

	var motion_normal = lateral_motion.normalized()
	var motion_binormal = motion_normal.cross(Vector3.UP).normalized()

	var shape = get_shape()

	var intersections: = []
	var rays = range( - 5, 6)
	for i in range( - 5, 6):
		
		var fac = float(i) / float(rays.size() - 1)
		fac *= 2.0
		var from = foot_position + motion_binormal * fac
		var to = from + lateral_motion

		var vertical_motion = Vector3.UP * shape.height

		if DEBUG:
			frame_data.add_debug_line(from, to, color)

		var result: = intersect_ray(from, to)
		if result.empty():
			from += vertical_motion
			to += vertical_motion
			vertical_motion *= - 1
			result = intersect_ray(from, to)

			if DEBUG:
				frame_data.add_debug_line(from, to, color)

		if result.empty():
			var vertical_result = intersect_ray(to, to + vertical_motion)

			if DEBUG:
				frame_data.add_debug_line(to, to + vertical_motion, color)

			if vertical_result.empty():
				var back_result = intersect_ray(to + vertical_motion, vertical_motion)

				if DEBUG:
					frame_data.add_debug_line(to + vertical_motion, from + vertical_motion, color)

				if not back_result.empty():
					if DEBUG:
						frame_data.add_debug_trace_result("Trace Closest Surface", back_result, color)
					var delta = back_result.position - to
					result = intersect_ray(from + Vector3(0, delta.y, 0), to + Vector3(0, delta.y, 0))
			else :
				if DEBUG:
					frame_data.add_debug_trace_result("Trace Closest Surface", vertical_result, color)
				var delta = vertical_result.position - to
				result = intersect_ray(from + Vector3(0, delta.y, 0), to + Vector3(0, delta.y, 0))

		if not result.empty():
			intersections.append(result)

	frame_data.debug_log("Intersection count: %s" % [intersections.size()])

	if intersections.size() == 0:
		return {}

	var binormal_from = foot_position + lateral_motion.normalized() * get_shape().radius

	var binormal_delta = motion_binormal * get_shape().radius * 2.0
	var binormal_to = binormal_from + binormal_delta
	var binormal_result = debug_intersect_ray(frame_data, "Binormal Ridge", get_color(), binormal_from, binormal_to)
	if binormal_result.empty():
		binormal_delta = - motion_binormal * get_shape().radius * 2.0
		binormal_to = binormal_from + binormal_delta
		binormal_result = debug_intersect_ray(frame_data, "Binormal Ridge", get_color(), binormal_from, binormal_to)

	if binormal_result.empty():
		binormal_delta = - motion_normal * get_shape().radius * 2.0
		binormal_to = binormal_to + binormal_delta
		binormal_result = debug_intersect_ray(frame_data, "Binormal Ridge", get_color(), binormal_from, binormal_to)

	if not binormal_result.empty():
		if binormal_result.normal.dot(lateral_motion.normalized()) >= 0.0:
			var ridge = PhysicsUtil.find_ridge(
				frame_data, 
				Color.red, 
				get_world().direct_space_state, 
				binormal_result.position + lateral_motion.normalized() * 0.01, 
				(binormal_result.position + lateral_motion.normalized() * 0.01) - lateral_motion.normalized() * shape.radius, 
				[self], 
				1, 
				- binormal_delta.normalized(), 
				get_shape().radius
			)

			if ridge[0]:
				frame_data.debug_log("Found Ridge: %s" % [ridge])
				var result = ridge[2]
				var ridge_normal = (foot_position - ridge[2].position).normalized()
				result.normal = ridge_normal
				return result

	if intersections.size() == 1:
		return intersections[0]

	var normals = []
	for intersection in intersections:
		if not intersection.normal in normals:
			normals.append(intersection.normal)

	if normals.size() < 2:
		return intersections[0]

	var far_left = intersections[0]
	var far_right = intersections[ - 1]

	var ridge = PhysicsUtil.find_ridge(
		frame_data, 
		Color.red, 
		get_world().direct_space_state, 
		far_left.position + far_left.normal * 0.01, 
		far_right.position + far_right.normal * 0.01, 
		[self], 
		1, 
		- lateral_motion.normalized(), 
		lateral_motion.length()
	)

	var result = {}
	var normal = Vector3.ZERO

	if ridge[0]:
		
		_sort_position = ridge[2].position
		_sort_axis = motion_binormal
		intersections.sort_custom(self, "sort_by_distance_along_axis")
		intersections.resize(2)
		intersections.sort_custom(self, "sort_along_axis")

		var dot = motion_binormal.dot(ridge[2].position - foot_position)
		frame_data.debug_log("Dot: %s" % [dot], get_color())

		var closest_intersection
		if dot > 0.0:
			closest_intersection = intersections[0]
		else :
			closest_intersection = intersections[1]

		frame_data.add_debug_point("Corner", ridge[2].position, get_color())
		frame_data.add_debug_point("Closest", closest_intersection.position, get_color())

		var ridge_normal = (foot_position - ridge[2].position).normalized()

		var ridge_dot = ridge_normal.dot( - motion_normal)
		var closest_dot = closest_intersection.normal.dot( - motion_normal)

		if ridge_dot > closest_dot:
			result = ridge[2]
			normal = ridge_normal
		else :
			result = closest_intersection
			normal = closest_intersection.normal
	else :
		_sort_position = foot_position + lateral_motion.normalized() * get_shape().radius
		intersections.sort_custom(self, "sort_by_distance")
		normal = intersections[0].normal
		result = far_right

	if not result.empty():
		result.normal = normal

	return result

func lateralize_normal(normal:Vector3)->Vector3:
	normal.y = 0.0
	return normal.normalized()

func derive_surface_basis(
	frame_data:PhysicsUtil.FrameData, 
	from:Vector3, 
	to:Vector3, 
	motion_tangent:Vector3, 
	color:Color
)->Basis:
	var dir = (to - from).normalized()
	var rad = TAU / 3.0

	var v0_offset = motion_tangent * 0.01
	var v1_offset = motion_tangent.rotated(dir, rad) * 0.01
	var v2_offset = motion_tangent.rotated(dir, rad * 2.0) * 0.01

	var v0_result = debug_intersect_ray(frame_data, "Derive Surface Normal / v0", color, from, to + v0_offset)
	var v1_result = debug_intersect_ray(frame_data, "Derive Surface Normal / v1", color, from, to + v1_offset)
	var v2_result = debug_intersect_ray(frame_data, "Derive Surface Normal / v2", color, from, to + v2_offset)

	var basis = Basis.IDENTITY
	if not v0_result.empty() and not v1_result.empty() and not v2_result.empty():
		var v0 = v0_result.position
		var v1 = v1_result.position
		var v2 = v2_result.position

		var v0v1 = v1 - v0
		var v0v2 = v2 - v0
		basis.y = v0v2.normalized().cross(v0v1.normalized()).normalized()
		basis.x = motion_tangent.cross(basis.y).normalized()
		basis.z = basis.y.cross(basis.x).normalized()

		frame_data.add_debug_line(v0, v0 + basis.x, Color.red)
		frame_data.add_debug_line(v1, v1 + basis.y, Color.green)
		frame_data.add_debug_line(v2, v2 + basis.z, Color.blue)

	return basis

func step_lateral(lateral_motion:Vector3, max_slides:int = 4)->void :
	assert (lateral_motion.y == 0.0)

	var frame_data = PhysicsUtil.FrameData.new()
	reset_color()

	if DEBUG:
		frame_data.debug_log("Tester %s: %s" % [get_name(), debug_motion])

	if lateral_motion.length() <= 0.0:
		return 

	frame_data.add_debug_arrow(global_transform.origin, global_transform.origin + lateral_motion, Color.white)

	var lateral_motion_normal = lateral_motion.normalized()
	var lateral_motion_tangent = lateral_motion_normal.cross(Vector3.UP).normalized()

	if DEBUG:
		frame_data.debug_log("Step Lateral: %s" % [lateral_motion], get_color())

	var progress: = 1.0
	var stepped_up: = false
	var wants_slide: = false
	var slide_motion: = Vector3.ZERO
	var shape = get_shape()
	var closest_surface_trace = lateral_motion.normalized() * (2.0 * shape.radius + lateral_motion.length())

	var foot_position = global_transform.origin + (Vector3.DOWN * shape.height * 0.5)

	if DEBUG:
		frame_data.add_debug_point("Foot Position", foot_position, get_color())

	var intersect_result:Dictionary

	
	intersect_result = intersect_ray(foot_position + floor_offset, foot_position - floor_offset)
	var floor_offset = Vector3.ZERO
	if not intersect_result.empty():
		floor_offset = intersect_result.position - (foot_position + floor_offset)
		floor_offset.y = max(floor_offset.y, 0.001)
	else :
		floor_offset.y = 0.001

	
	var closest_surface_color = get_color()

	if DEBUG:
		frame_data.debug_log("Tracing closest surface", closest_surface_color)

	var closest_surface_from = foot_position + floor_offset
	intersect_result = trace_closest_surface(frame_data, closest_surface_color, closest_surface_from, closest_surface_trace, trace_count)
	if not intersect_result.empty():
		if DEBUG:
			frame_data.add_debug_trace_result("Closest Surface Trace", intersect_result, get_color())

		var surface_normal_color = get_color()
		var from_lateral = Vector3(closest_surface_from.x, intersect_result.position.y, closest_surface_from.z)

		
		var lateral_normal = lateralize_normal(intersect_result.normal)
		frame_data.add_debug_line(intersect_result.position, intersect_result.position + lateral_normal, Color.white)
		var edge_offset = - lateral_normal * (shape.radius - 0.001)

		
		var toward_surface_from = Vector3(foot_position.x, intersect_result.position.y, foot_position.z) + floor_offset
		var toward_surface_to = toward_surface_from + edge_offset * 2.0

		var toward_surface_color = get_color()
		intersect_result = debug_intersect_ray(frame_data, "Toward Surface", toward_surface_color, toward_surface_from, toward_surface_to)
		if not intersect_result.empty():
			
			var delta = intersect_result.position - toward_surface_from - floor_offset
			var dist = delta.length() - shape.radius
			var motion_dot = lateral_motion.dot( - lateral_normal)

			if DEBUG:
				frame_data.debug_log("Distance: %s" % [dist], toward_surface_color)
				frame_data.debug_log("Motion Dot Normal: %s" % [motion_dot], toward_surface_color)

			
			if motion_dot > 0.0:
				progress = clamp(dist / motion_dot, - 1.0, 1.0)

				if progress < 1.0:
					var remainder = 1.0 - progress
					var remainder_motion = lateral_motion * remainder
					var absorbed_motion = - lateral_normal * remainder_motion.dot( - lateral_normal)
					emit_signal("lateral_motion_absorbed", absorbed_motion)
					slide_motion = remainder_motion - absorbed_motion

			
			var foot_start = foot_position + edge_offset
			var step_up_vec = Vector3.UP * (shape.height + step_distance)

			var step_up_upward_from = foot_start + floor_offset
			var step_up_upward_to = step_up_upward_from + step_up_vec
			var trace_step_up_color = get_color()
			intersect_result = debug_intersect_ray(frame_data, "Step Up / Upward", trace_step_up_color, step_up_upward_from, step_up_upward_to)

			var new_from = step_up_upward_to
			var hit_ceiling = false
			if not intersect_result.empty():
				if DEBUG:
					frame_data.debug_log("Hit surface while stepping up: %s" % [intersect_result], trace_step_up_color)

				delta = intersect_result.position - step_up_upward_from
				dist = delta.dot(Vector3.UP)

				if DEBUG:
					frame_data.debug_log("Delta: %s, Dist: %s" % [delta, dist], trace_step_up_color)

				new_from = intersect_result.position - (Vector3.UP * 0.001)
				hit_ceiling = true

			var step_up_forward_from = new_from
			var step_up_forward_to = step_up_forward_from + lateral_motion
			intersect_result = debug_intersect_ray(frame_data, "Step Up / Forward", get_color(), step_up_forward_from, step_up_forward_to)

			if intersect_result.empty():
				var step_up_downward_from = step_up_forward_to
				var step_up_downward_to = step_up_downward_from - step_up_vec - floor_offset
				var step_up_downward_color = get_color()
				intersect_result = debug_intersect_ray(frame_data, "Step Up / Downward", step_up_downward_color, step_up_downward_from, step_up_downward_to)

				var step_up_downward_intersect
				if intersect_result.empty():
					frame_data.debug_log("Step Up / Downward - No Intersect", step_up_downward_color)
					delta = step_up_downward_to - step_up_downward_from
					step_up_downward_intersect = step_up_downward_to
				else :
					frame_data.debug_log("Step Up / Downward - Intersect: %s" % [intersect_result], step_up_downward_color)
					delta = intersect_result.position - step_up_upward_from
					step_up_downward_intersect = intersect_result.position + Vector3.UP * 0.001

				if DEBUG:
					frame_data.debug_log("Destination delta: %s, height: %s" % [delta, delta.length()], step_up_downward_color)
					frame_data.debug_log("Hit ceiling: %s, Delta lower than shape height? %s" % [hit_ceiling, delta.length() < shape.height], step_up_downward_color)

				if hit_ceiling and delta.length() < shape.height:
					progress = 0.0
					stepped_up = true
				else :
					var step_up_backward_color = get_color()
					var vertical_delta = step_up_downward_intersect.y - foot_start.y

					frame_data.debug_log("Trying step up backward", step_up_backward_color)

					if DEBUG:
						frame_data.debug_log("Vertical delta: %s, step_distance: %s" % [vertical_delta, step_distance], step_up_backward_color)

					if vertical_delta >= 0.0 and vertical_delta < step_distance:
						var step_up_backward_from = step_up_downward_intersect
						var step_up_backward_to = step_up_backward_from - lateral_motion
						var ridge_intersect_result = debug_intersect_ray(frame_data, "Step Up / Backward", step_up_backward_color, step_up_backward_from, step_up_backward_to)

						if ridge_intersect_result.empty():
							if DEBUG:
								frame_data.debug_log("Stepped up.", step_up_backward_color)

							var surface_basis = derive_surface_basis(frame_data, foot_start, step_up_downward_to, Vector3.UP, step_up_backward_color)

							if surface_basis == Basis.IDENTITY:
								global_transform.origin.y += vertical_delta
								progress = 1.0
								stepped_up = true
								emit_signal("stepped_up", vertical_delta)
							else :
								var forward = surface_basis.z.dot(Vector3.UP.cross(surface_basis.x).normalized())
								var up = surface_basis.z.dot(Vector3.UP)
								var angle = atan2(up, forward)
								frame_data.debug_log("Surface angle: %s, max slope angle: %s" % [angle, deg2rad(max_slope_angle)])

								if angle <= deg2rad(max_slope_angle) or angle >= deg2rad(89.0):
									global_transform.origin.y += vertical_delta
									progress = 1.0
									stepped_up = true
									emit_signal("stepped_up", vertical_delta)
								else :
									progress = 0.0
						else :
							var result = PhysicsUtil.find_ridge(
								frame_data, 
								get_color(), 
								get_world().direct_space_state, 
								step_up_backward_to, 
								step_up_backward_from, 
								[self], 
								collision_mask, 
								Vector3.UP, 
								shape.height
							)

							delta = result[1] - foot_start.y
							if delta > 0.0 and delta < step_distance:
								global_transform.origin.y = result[1] + shape.height * 0.5
								progress = 1.0
								stepped_up = true
								emit_signal("stepped_up", delta)

	if DEBUG:
		frame_data.debug_log("Pre step down progress: %s" % [progress])

	foot_position += lateral_motion * progress

	
	if not stepped_up:
		wants_slide = true

		var step_down_vec = Vector3.DOWN * step_distance
		intersect_result = debug_intersect_ray(
			frame_data, 
			"Step Down / Center Trace Down", 
			get_color(), 
			foot_position + floor_offset, 
			foot_position + floor_offset + step_down_vec
		)
		if not intersect_result.empty():
			var trace_nearest_surface_color = get_color()

			if DEBUG:
				frame_data.debug_log("Tracing nearest surface", trace_nearest_surface_color)

			intersect_result = trace_closest_surface(frame_data, trace_nearest_surface_color, intersect_result.position + Vector3.UP * 0.001, - closest_surface_trace, trace_count)
			if not intersect_result.empty():
				
				var lateral_normal = lateralize_normal(intersect_result.normal)
				if intersect_result.normal.dot(lateral_motion.normalized()) > 0.75:
					if DEBUG:
						frame_data.add_debug_trace_result("Step Down / Trace Nearest Surface", intersect_result, trace_nearest_surface_color)


					var edge_start_offset = lateral_normal * shape.radius
					var edge_end_offset = - lateral_normal * shape.radius
					var foot_start = foot_position + edge_end_offset

					if DEBUG:
						frame_data.add_debug_point("Foot Start", foot_start, get_color())

					var step_down_edge_from = foot_start + floor_offset
					var step_down_edge_to = step_down_edge_from + step_down_vec
					intersect_result = debug_intersect_ray(frame_data, "Step Down / Edge Trace Down", get_color(), step_down_edge_from, step_down_edge_to)
					if not intersect_result.empty():
						var step_down_across_from = foot_position + edge_start_offset
						step_down_across_from.y = intersect_result.position.y + floor_offset.y
						var step_down_across_to = foot_position + edge_end_offset
						step_down_across_to.y = intersect_result.position.y + floor_offset.y

						var trace_step_down_across_color = get_color()
						intersect_result = debug_intersect_ray(frame_data, "Step Down / Trace Across", trace_step_down_across_color, step_down_across_from, step_down_across_to)
						if intersect_result.empty():
							var delta = step_down_across_from.y - foot_start.y

							if DEBUG:
								frame_data.debug_log("Trace step down delta: %s" % [delta], trace_step_down_across_color)

							if delta < 0.0:
								global_transform.origin.y += delta
								emit_signal("stepped_down", delta)

	if DEBUG:
		frame_data.debug_log("Progress: %s\n" % [progress])

	global_transform.origin += lateral_motion * progress

	frame_data.position = global_transform.origin
	_frame_history[ - 1].lateral.append(frame_data)

	if DEBUG:
		frame_data.debug_log("Slide motion: %s" % [slide_motion], get_color())
	if max_slides > 0 and wants_slide and slide_motion.length() > 0.0:
		step_lateral(slide_motion, max_slides - 1)

func step_vertical(vertical_velocity:Vector3, max_slides:int = 4)->void :
	assert (vertical_velocity.x == 0.0 and vertical_velocity.z == 0.0)

	var slide_motion = Vector3.ZERO
	var wants_slide = false

	var frame_data = PhysicsUtil.FrameData.new()
	reset_color()

	if DEBUG:
		frame_data.debug_log("Tester %s: %s" % [get_name(), debug_motion])

	if vertical_velocity.length() <= 0.0:
		return 

	if DEBUG:
		frame_data.debug_log("Step Vertical", get_color())

	var shape = get_shape()
	var progress = 1.0

	var endpoint = Vector3.UP * shape.height * 0.5 * sign(vertical_velocity.y)

	var base = global_transform.origin + endpoint + (Vector3.UP * vertical_velocity.y * 0.9)

	var ground_center = base
	var delta = vertical_velocity
	var dist = vertical_velocity.length()

	var step_vertical_center_from = global_transform.origin
	var step_vertical_center_to = step_vertical_center_from + endpoint + vertical_velocity

	var intersect_result = debug_intersect_ray(frame_data, "Center", get_color(), step_vertical_center_from, step_vertical_center_to)
	if not intersect_result.empty():
		ground_center = intersect_result.position

		delta = ground_center - (step_vertical_center_from + endpoint)
		dist = delta.dot(endpoint.normalized())

	var find_nearest_surface_color = get_color()

	if DEBUG:
		frame_data.debug_log("Finding nearest surface", find_nearest_surface_color)

	var closest_dist = vertical_velocity.length()
	var closest_intersect: = {}
	var nearest_surface_from = Vector3(base.x, ground_center.y + 0.001, base.z)
	var closest_norm = Vector3.ZERO
	for i in range(0, 16):
		
		var rad = (float(i) / 16.0) * TAU
		var norm = Vector3.FORWARD.rotated(Vector3.UP, rad)
		var nearest_surface_to = nearest_surface_from + norm

		if DEBUG:
			frame_data.add_debug_arrow(nearest_surface_from, nearest_surface_to, find_nearest_surface_color)

		var local_intersect_result = intersect_ray(nearest_surface_from, nearest_surface_to)
		if not local_intersect_result.empty():
			var local_delta = local_intersect_result.position - nearest_surface_from - (norm * shape.radius)
			var local_dist = local_delta.dot(Vector3.UP)
			if local_dist < closest_dist:
				closest_dist = local_dist
				closest_intersect = local_intersect_result
				closest_norm = norm

	if closest_intersect.empty():
		if DEBUG:
			frame_data.debug_log("No closest intersection", find_nearest_surface_color)

		progress = dist / vertical_velocity.length()
		emit_signal("vertical_motion_absorbed", vertical_velocity * (1.0 - progress))
	else :
		if DEBUG:
			frame_data.debug_log("Closest intersection: %s" % [closest_intersect], find_nearest_surface_color)

		var lateral_normal = lateralize_normal(closest_intersect.normal)

		var surface_basis_color = get_color()
		var surface_basis = derive_surface_basis(frame_data, nearest_surface_from, nearest_surface_from + closest_norm * 2.0, Vector3.UP, surface_basis_color)

		delta = closest_intersect.position - (step_vertical_center_from + Vector3.UP * shape.height * 0.5 * sign(vertical_velocity.y))
		dist = delta.dot(Vector3.UP)
		base = global_transform.origin + endpoint + (Vector3.UP * sign(vertical_velocity.y) * (dist - 0.1))

		var edge_start_offset = lateral_normal * shape.radius
		var edge_end_offset = - lateral_normal * shape.radius

		var step_vertical_edge_from = global_transform.origin + edge_end_offset
		var step_vertical_edge_to = step_vertical_edge_from + endpoint + vertical_velocity

		intersect_result = debug_intersect_ray(frame_data, "Edge Trace", get_color(), step_vertical_edge_from, step_vertical_edge_to)
		var step_vertical_across_from
		if not intersect_result.empty():
			step_vertical_across_from = intersect_result.position + Vector3.UP * 0.001
		else :
			step_vertical_across_from = step_vertical_edge_to

		var step_vertical_across_to = step_vertical_across_from + edge_start_offset * 2.0
		var vertical_movement_trace_across_color = get_color()

		intersect_result = debug_intersect_ray(frame_data, "Trace Across", vertical_movement_trace_across_color, step_vertical_across_from, step_vertical_across_to)
		if intersect_result.empty():
			delta = step_vertical_across_to - (global_transform.origin + endpoint + edge_start_offset)
			dist = delta.dot(Vector3.UP * sign(vertical_velocity.y))
			progress = dist / vertical_velocity.length()

			if progress < 1.0:
				var remainder = 1.0 - progress
				var remainder_motion = vertical_velocity * remainder
				var absorbed_motion = - surface_basis.y * remainder_motion.dot( - surface_basis.y)
				slide_motion = remainder_motion - absorbed_motion

				if surface_basis != Basis.IDENTITY:
					var forward = surface_basis.z.dot(Vector3.UP.cross(surface_basis.x).normalized())
					var up = surface_basis.z.dot(Vector3.UP)
					var angle = atan2(up, forward)
					frame_data.debug_log("Surface angle: %s, max slope angle: %s" % [angle, deg2rad(max_slope_angle)])
					wants_slide = angle > deg2rad(max_slope_angle)

			if DEBUG:
				frame_data.debug_log("Trace Across / Moved Vertically. Delta: %s, Dist: %s, Progress: %s" % [delta, dist, progress], vertical_movement_trace_across_color)
				frame_data.debug_log("Slide Motion: %s" % [slide_motion])
		else :
			if DEBUG:
				frame_data.debug_log("Trace Across / Blocked", vertical_movement_trace_across_color)

			progress = 0.0

	global_transform.origin += vertical_velocity * progress

	frame_data.position = global_transform.origin
	_frame_history[ - 1].vertical.append(frame_data)

	if progress >= 1.0:
		_is_on_floor = false
	else :
		_is_on_floor = true

	if max_slides > 0 and wants_slide and slide_motion.length() > 0.0:
		step_lateral(Vector3(slide_motion.x, 0.0, slide_motion.z), 1)
		step_vertical(Vector3(0.0, slide_motion.y, 0.0), max_slides - 1)

func step_back()->void :
	if _frame_history.size() <= 1:
		return 

	var index = _frame_history.size() - 1
	global_transform.origin = _frame_history[index - 1].vertical[ - 1].position
	_frame_history.remove(index)

	emit_signal("stepped")

func get_debug_draw()->ImmediateGeometry:
	return get_node_or_null("DebugDraw/ImmediateGeometry") as ImmediateGeometry

func debug_draw_end()->void :
	var debug: = get_debug_draw()
	if not debug:
		return 

	debug.end()

func debug_draw_line(from:Vector3, to:Vector3, color:Color)->void :
	var debug: = get_debug_draw()
	if not debug:
		return 

	debug.set_color(color)
	debug.add_vertex(from)
	debug.add_vertex(to)

func _input_event(camera:Object, event:InputEvent, click_position:Vector3, click_normal:Vector3, shape_idx:int)->void :
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				emit_signal("pressed")
