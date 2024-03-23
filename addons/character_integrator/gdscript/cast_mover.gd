class_name CastMover

var motions: = []
var results:Results = null

var _state:PhysicsDirectSpaceState = null
var _query:PhysicsShapeQueryParameters = null
var _failed:bool = false

func setup(state:PhysicsDirectSpaceState, from:Transform, shape:Shape, collision_mask:int, exclude:Array = []):
	var scope = Profiler.scope(self, "setup", [state, from, shape, collision_mask, exclude])

	motions.clear()

	results = Results.new(from)

	_state = state

	_query = PhysicsShapeQueryParameters.new()
	_query.set_shape(shape)
	_query.transform = from
	_query.collision_mask = collision_mask
	_query.margin = shape.margin
	_query.exclude = exclude

	_failed = false

	return self

func set_transform(trx:Transform)->void :
	var scope = Profiler.scope(self, "set_transform", [trx])

	_query.transform = trx

func _to_string()->String:
	return "[CastMover]"

func move(motion:Motion):
	var scope = Profiler.scope(self, "move", [motion])

	if _failed:
		return self

	motions.append(motion)

	var vector = motion.vector + (motion.vector.normalized() * motion.extra_dist)
	var result_arr = _state.cast_motion(_query, vector)
	var res_motion = Vector3.ZERO
	if not result_arr.empty():
		res_motion = vector * result_arr[0]

	var result = Result.new(motion, result_arr)

	match motion.mode:
		Motion.Mode.Unobstructed:
			if result.safe_move_dist < 1.0:
				_failed = true
				return self
		Motion.Mode.Obstructed:
			if result.safe_move_dist == 1:
				_failed = true
				return self

	var last_origin = _query.transform.origin
	_query.transform.origin += result.motion.vector * result.collision_dist
	results.rest_info = _state.get_rest_info(_query)
	_query.transform.origin = last_origin

	_query.transform.origin += vector * result.safe_move_dist

	if result.safe_move_dist >= motion.extra_dist:
		_query.transform.origin -= vector.normalized() * motion.extra_dist

	results.push_result(result)
	return self

func success()->bool:
	var scope = Profiler.scope(self, "success", [])

	return results != null and not _failed

func failure()->bool:
	var scope = Profiler.scope(self, "failure", [])

	return results != null and _failed

class Motion:
	enum Mode{
		
		Continuous, 
		
		Unobstructed, 
		
		Obstructed, 
	}

	" The vector to move along "
	var vector:Vector3

	" If true, this move will fail on collision "
	var mode:int

	" Additional distance to be added to the sweep check, then subtracted from the result "
	var extra_dist:float

	func _init(in_vector:Vector3, in_mode:int = Mode.Continuous, in_extra_dist:float = 0.0)->void :
		var scope = Profiler.scope(self, "_init", [in_vector, in_mode, in_extra_dist])

		vector = in_vector
		mode = in_mode
		extra_dist = in_extra_dist

	func _to_string()->String:
		var scope = Profiler.scope(self, "_to_string", [])

		return "Motion { vector: %s, mode: %s }" % [vector, Mode.keys()[mode]]

class Result:
	var motion:Motion = null
	var safe_move_dist: = 0.0
	var collision_dist: = 0.0

	func _init(in_motion:Motion, in_result_arr:Array):
		var scope = Profiler.scope(self, "_init", [in_motion, in_result_arr])

		motion = in_motion
		if not in_result_arr.empty():
			safe_move_dist = in_result_arr[0]
			collision_dist = in_result_arr[1]

	func _to_string()->String:
		return "Result { motion: %s, safe_move_dist: %s, collision_dist: %s }" % [motion, safe_move_dist, collision_dist]

class Results:
	var from:Transform
	var to:Transform
	var results:Array
	var rest_info:Dictionary

	func _init(in_from:Transform):
		var scope = Profiler.scope(self, "_init", [in_from])

		from = in_from
		to = in_from
		results = []

	func push_result(result:Result):
		var scope = Profiler.scope(self, "push_result", [result])

		results.append(result)
		to.origin += result.motion.vector * result.safe_move_dist

	func _to_string()->String:
		return "Results { from: %s, to: %s, results: %s }" % [from, to, results]

	func draw_debug(geo:ImmediateGeometry)->void :
		var scope = Profiler.scope(self, "draw_debug", [geo])

		var pos = from.origin
		var prev_pos = from.origin
		for result in results:
			var vector = result.motion.vector
			var res_motion = result.safe_move_dist * vector
			pos += res_motion
			geo.begin(Mesh.PRIMITIVE_LINES)
			_draw_debug_line(geo, pos, pos + (vector - res_motion), Color.red)
			_draw_debug_line(geo, prev_pos, pos, Color.green)
			geo.end()
			prev_pos = pos

		_draw_debug_point(geo, from, Color.white)
		_draw_debug_point(geo, to, Color.white)

	func _draw_debug_point(geo:ImmediateGeometry, trx:Transform, color:Color)->void :
		var scope = Profiler.scope(self, "_draw_debug_point", [geo, trx, color])

		geo.begin(Mesh.PRIMITIVE_LINES)
		_draw_debug_line(geo, trx.xform(Vector3.LEFT * 0.5), trx.xform(Vector3.RIGHT * 0.5), color)
		_draw_debug_line(geo, trx.xform(Vector3.DOWN * 0.5), trx.xform(Vector3.UP * 0.5), color)
		_draw_debug_line(geo, trx.xform(Vector3.BACK * 0.5), trx.xform(Vector3.FORWARD * 0.5), color)
		geo.end()

	func _draw_debug_line(geo:ImmediateGeometry, from:Vector3, to:Vector3, color:Color)->void :
		var scope = Profiler.scope(self, "_draw_debug_line", [geo, from, to, color])

		geo.set_color(color)
		geo.add_vertex(from)
		geo.add_vertex(to)
