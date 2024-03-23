class_name PhysicsUtil
tool 

const DEBUG: = true

class FrameData:
	class DebugLine:
		var from:Vector3
		var to:Vector3
		var color:Color

	var position: = Vector3.ZERO
	var debug_lines: = []
	var debug_log: = []

	func debug_log(string:String, color:Color = Color.white)->void :
		debug_log.append("[color=#%s]%s[/color]" % [color.to_html(), string])

	func add_debug_line(from:Vector3, to:Vector3, color:Color)->void :
		var debug_line = DebugLine.new()
		debug_line.from = from
		debug_line.to = to
		debug_line.color = color
		debug_lines.append(debug_line)

	func add_debug_point(name:String, point:Vector3, color:Color)->void :
		debug_log("%s: %s" % [name, point], color)
		add_debug_octahedron(point, 0.25, color)

	func add_debug_octahedron(position:Vector3, radius:float, color:Color)->void :
		add_debug_diamond(position, Vector3.RIGHT, Vector3.UP, radius, color)
		add_debug_diamond(position, Vector3.FORWARD, Vector3.UP, radius, color)
		add_debug_diamond(position, Vector3.RIGHT, Vector3.FORWARD, radius, color)

	func add_debug_diamond(position, x_axis, y_axis, radius, color)->void :
		add_debug_line(position + y_axis * radius, position + x_axis * radius, color)
		add_debug_line(position + x_axis * radius, position - y_axis * radius, color)
		add_debug_line(position - y_axis * radius, position - x_axis * radius, color)
		add_debug_line(position - x_axis * radius, position + y_axis * radius, color)

	func add_debug_triangle(position, x_axis, y_axis, width, height, color)->void :
		add_debug_line(position - x_axis * width * 0.5, position + y_axis * height, color)
		add_debug_line(position + y_axis * height, position + x_axis * width * 0.5, color)

	func add_debug_arrow(from, to, color)->void :
		var delta = to - from
		var delta_norm = delta.normalized()
		var base_axis = Vector3.UP
		if abs(delta_norm.dot(base_axis)) == 1.0:
			base_axis = Vector3.RIGHT

		var x_axis = delta.normalized().cross(base_axis)
		var y_axis = delta.normalized().cross(x_axis)

		add_debug_diamond(from, x_axis, y_axis, 0.125 * 0.5, color)
		add_debug_triangle(from, x_axis, delta.normalized(), 0.125, delta.length(), color)
		add_debug_triangle(from, y_axis, delta.normalized(), 0.125, delta.length(), color)

	func add_debug_trace(name:String, from:Vector3, to:Vector3, color:Color)->void :
		debug_log("%s: %s > %s" % [name, from, to], color)
		add_debug_arrow(from, to, color)

	func add_debug_trace_result(name:String, trace_result:Dictionary, color:Color)->void :
		debug_log("%s Result: %s" % [name, trace_result], color)
		add_debug_line(trace_result.position, trace_result.position + trace_result.normal, color)

	func debug_draw_line(immediate_geometry:ImmediateGeometry, from:Vector3, to:Vector3, color:Color)->void :
		immediate_geometry.set_color(color)
		immediate_geometry.add_vertex(from)
		immediate_geometry.add_vertex(to)

	func debug_draw(immediate_geometry:ImmediateGeometry)->void :
		for debug_line in debug_lines:
			debug_draw_line(immediate_geometry, debug_line.from, debug_line.to, debug_line.color)

static func debug_intersect_ray(
	frame_data:FrameData, 
	name:String, 
	color:Color, 
	direct_space_state:PhysicsDirectSpaceState, 
	from:Vector3, 
	to:Vector3, 
	exclude:Array, 
	collision_mask:int
)->Dictionary:
	if DEBUG:
		frame_data.add_debug_trace("%s Trace" % [name], from, to, color)

	var result = direct_space_state.intersect_ray(from, to, exclude, collision_mask, true, false)

	if DEBUG:
		if not result.empty():
			frame_data.add_debug_trace_result("%s Trace Result" % [name], result, color)

	return result


static func find_ridge(
	frame_data:FrameData, 
	color:Color, 
	direct_space_state:PhysicsDirectSpaceState, 
	from:Vector3, 
	to:Vector3, 
	exclude:Array, 
	collision_mask:int, 
	normal:Vector3, 
	distance:float, 
	max_iterations:int = 30, 
	epsilon:float = 0.001
)->Array:
	var offset = 0.0
	var step_size = abs(distance) - 0.1
	var step_sign = sign(distance)

	var last_intersect = {}
	while max_iterations > 0:
		max_iterations -= 1

		var new_from = from + normal * offset
		var new_to = to + normal * offset

		var ridge_intersect_result = debug_intersect_ray(frame_data, "Find Ridge", color, direct_space_state, new_from, new_to, exclude, collision_mask)
		if not ridge_intersect_result.empty():
			last_intersect = ridge_intersect_result

		var step_away_unblocked = step_sign == sign(distance) and ridge_intersect_result.empty()
		var step_toward_blocked = step_sign != sign(distance) and not ridge_intersect_result.empty()

		if step_away_unblocked or step_toward_blocked:
			if step_away_unblocked and step_size <= epsilon:
				return [true, new_from.y, last_intersect]

			step_sign *= - 1
			step_size *= 0.5

		offset += step_size * step_sign

		if sign(offset) == - sign(distance):
			
			return [false, 0.0]

		if abs(offset) > abs(distance):
			
			return [false, 0.0]

	
	return [false, 0.0]
