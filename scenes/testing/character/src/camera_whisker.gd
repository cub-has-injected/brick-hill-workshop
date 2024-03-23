class_name CameraWhisker
extends Resource
tool 

export (Vector3) var normal: = Vector3.FORWARD

export (float) var horizontal_range: = 3.0
export (int) var horizontal_count: = 3

export (float) var vertical_range: = 1.0
export (int) var vertical_count: = 1

func _init()->void :
	if resource_name.empty():
		resource_name = "Camera Whisker"

func trace(direct_space_state:PhysicsDirectSpaceState, transform:Transform, distance:float, exclude:Array)->Array:
	var furthest_dist = distance

	var closest_dist = furthest_dist
	for y in range(0, vertical_count):
		for x in range(0, horizontal_count):
			var end = get_endpoint(x, y) * distance
			end = transform.basis.xform(end)
			var result = direct_space_state.intersect_ray(
				transform.origin, 
				transform.origin + end, 
				[exclude], 
				1, 
				true, 
				false
			)

			if not result.empty():
				var dist = (result.position - transform.origin).length()
				if dist < closest_dist:
					closest_dist = dist

	return [closest_dist, furthest_dist]

func draw(immediate_geometry:ImmediateGeometry, trx:Transform, distance:float, color:Color)->void :
	immediate_geometry.begin(Mesh.PRIMITIVE_LINES)
	immediate_geometry.set_color(color)
	for y in range(0, vertical_count):
		for x in range(0, horizontal_count):
			var end = get_endpoint(x, y) * distance
			immediate_geometry.add_vertex(trx.xform(Vector3.ZERO))
			immediate_geometry.add_vertex(trx.xform(end))
	immediate_geometry.end()

func get_endpoint(x:int, y:int)->Vector3:
	var end = normal
	var horizontal_step = horizontal_range / float(horizontal_count)
	var vertical_step = vertical_range / float(vertical_count)
	var right = normal.cross(Vector3.UP).normalized()
	var up = right.cross(normal).normalized()
	end -= right * horizontal_step * (float(horizontal_count - 1) * 0.5)
	end += right * horizontal_step * x
	end += up * vertical_step * y
	end = end.normalized()
	return end
