class_name CubemapPanorama
extends ImageTexture
tool 

signal panorama_generated()


var reload: = false setget set_reload
var filter: = true

var cubemap_texture
var grid_size: = Vector2(4.0, 3.0)

var cell_right: = Vector2(3, 1)
var cell_left: = Vector2(1, 1)
var cell_top: = Vector2(1, 0)
var cell_bottom: = Vector2(1, 2)
var cell_back: = Vector2(0, 1)
var cell_front: = Vector2(2, 1)

var icon:ImageTexture


var start_ts: = - 1

var job_system:JobSystem = null

var cubemap_image:Image = null


func set_reload(new_reload:bool)->void :
	var scope = Profiler.scope(self, "set_reload", [new_reload])

	if reload != new_reload:
		convert_cubemap()


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	if flags == Texture.FLAGS_DEFAULT:
		flags = FLAG_REPEAT | FLAG_FILTER | FLAG_CONVERT_TO_LINEAR

	job_system = JobSystem.new()
	job_system.connect("jobs_finished", self, "jobs_finished")

func _get_property_list()->Array:
	var scope = Profiler.scope(self, "_get_property_list", [])

	return [
		{
			"name":"Panorama", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_CATEGORY
		}, 
		{
			"name":"reload", 
			"type":TYPE_BOOL
		}, 
		{
			"name":"filter", 
			"type":TYPE_BOOL
		}, 
		{
			"name":"CubeMap", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_CATEGORY
		}, 
		{
			"name":"cubemap_texture", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"Texture"
		}, 
		{
			"name":"Grid", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_GROUP
		}, 
		{
			"name":"grid_size", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_top", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_bottom", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_right", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_left", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_top", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_bottom", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_back", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"cell_front", 
			"type":TYPE_VECTOR2
		}, 
		{
			"name":"UI", 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_CATEGORY
		}, 
		{
			"name":"icon", 
			"type":TYPE_OBJECT, 
			"hint":PROPERTY_HINT_RESOURCE_TYPE, 
			"hint_string":"ImageTexture"
		}, 
	]


func convert_cubemap()->void :
	var scope = Profiler.scope(self, "convert_cubemap", [])

	if not cubemap_texture:
		create(0, 0, Image.FORMAT_RGB8)
		return 

	print_debug("Generating panorama")
	start_ts = OS.get_ticks_msec()

	cubemap_image = cubemap_texture.get_data().duplicate()
	cubemap_image.decompress()
	cubemap_image.lock()

	var panorama_resolution = get_panorama_resolution(cubemap_image)
	job_system.run_jobs_array_spread(self, "generate_panorama", panorama_resolution.y, {
		"cubemap_image":cubemap_image, 
		"panorama_resolution":panorama_resolution
	})

func jobs_finished(thread_results:Dictionary)->void :
	var scope = Profiler.scope(self, "jobs_finished", [thread_results])

	var bytes = PoolByteArray()
	for i in range(0, thread_results.size()):
		bytes.append_array(thread_results[i])

	var panorama = Image.new()
	var panorama_resolution = get_panorama_resolution(cubemap_image)

	cubemap_image.unlock()
	cubemap_image = null

	panorama.create_from_data(panorama_resolution.x, panorama_resolution.y, false, Image.FORMAT_RGB8, bytes)
	create_from_image(panorama, flags)

	var icon_image = panorama.duplicate()
	icon_image.resize(128, 64, Image.INTERPOLATE_LANCZOS)
	icon = ImageTexture.new()
	icon.create_from_image(icon_image)

	print_debug("Panorama generated in %s seconds" % [(OS.get_ticks_msec() - start_ts) / 1000.0])
	emit_signal("panorama_generated")

func get_panorama_resolution(cubemap:Image)->Vector2:
	var scope = Profiler.scope(self, "get_panorama_resolution", [cubemap])

	var panorama_resolution = get_size()
	if panorama_resolution == Vector2.ZERO:
		var cubemap_resolution = cubemap.get_size()
		panorama_resolution = Vector2(cubemap_resolution.x, cubemap_resolution.x * 0.5)
	return panorama_resolution

func generate_panorama(userdata:Dictionary)->PoolByteArray:
	var scope = Profiler.scope(self, "generate_panorama", [userdata])

	var job_index = userdata.job_index
	var cubemap = userdata.cubemap_image
	var start = userdata.start
	var end = userdata.end
	var panorama_resolution = userdata.panorama_resolution

	var cubemap_resolution = cubemap.get_size()

	var bytes = PoolByteArray()
	for y in range(start, end):
		for x in range(0, panorama_resolution.x):
			var coord = Vector2(x, y)
			var normalized_coord = coord / panorama_resolution
			var centered_coord = normalized_coord - Vector2(0.0, 0.5)
			var panorama_coord = cube_to_rectangle(centered_coord)

			var cubemap_data = read_cubemap(panorama_coord)
			var cubemap_coord = cubemap_data[0] * (cubemap_resolution - Vector2.ONE) + Vector2(0.5, 0.5)
			var cubemap_offset = cubemap_data[1]
			var cubemap_face_size = cubemap_data[2]

			var c:Color

			if filter:
				var scaled_min = cubemap_offset * cubemap_face_size * (cubemap_resolution - Vector2.ONE)
				var scaled_max = scaled_min + cubemap_face_size * (cubemap_resolution - Vector2.ONE)

				var uv1 = cubemap_coord + Vector2(1.0, 0.0)
				uv1.x = clamp(uv1.x, scaled_min.x, scaled_max.x)

				var uv2 = cubemap_coord + Vector2(0.0, 1.0)
				uv2.y = clamp(uv2.y, scaled_min.y, scaled_max.y)

				var uv3 = cubemap_coord + Vector2(1.0, 1.0)
				uv3.x = clamp(uv3.x, scaled_min.x, scaled_max.x)
				uv3.y = clamp(uv3.y, scaled_min.y, scaled_max.y)

				var c0 = cubemap_image.get_pixelv(cubemap_coord)
				var c1 = cubemap_image.get_pixelv(uv1)
				var c2 = cubemap_image.get_pixelv(uv2)
				var c3 = cubemap_image.get_pixelv(uv3)

				var f = cubemap_coord.posmod(1.0)
				var ta = lerp(c0, c1, f.x)
				var tb = lerp(c2, c3, f.x)
				c = lerp(ta, tb, f.y)
			else :
				c = cubemap_image.get_pixelv(cubemap_coord)

			bytes.append_array([c.r8, c.g8, c.b8])

	job_system.call_deferred("job_finished", job_index)
	return bytes

func cube_to_rectangle(rect_coordinate:Vector2)->Vector3:
	var scope = Profiler.scope(self, "cube_to_rectangle", [rect_coordinate])

	return Vector3(
		cos(rect_coordinate.x * TAU) * cos( - rect_coordinate.y * PI), 
		sin( - rect_coordinate.y * PI), 
		sin(rect_coordinate.x * TAU) * cos( - rect_coordinate.y * PI)
	)

func read_cubemap(cube_coordinate:Vector3)->Array:
	var scope = Profiler.scope(self, "read_cubemap", [cube_coordinate])

	var uvw:Vector3;
	var absr:Vector3 = cube_coordinate.abs()
	var offset: = Vector2.ZERO

	if absr.x >= absr.y and absr.x >= absr.z:
		var negx: = 1 if cube_coordinate.x > 0 else 0
		uvw = Vector3(cube_coordinate.z, cube_coordinate.y, absr.x) * Vector3(lerp( - 1.0, 1.0, negx), - 1, 1);
		offset = cell_front if negx else cell_back
	elif absr.y >= absr.x and absr.y >= absr.z:
		var negy: = 0 if cube_coordinate.y < 0 else 1
		uvw = Vector3(cube_coordinate.x, cube_coordinate.z, absr.y) * Vector3(1.0, lerp(1.0, - 1.0, negy), 1.0);
		offset = cell_top if negy else cell_bottom
	elif absr.z >= absr.x and absr.z >= absr.y:
		var negz: = 1 if cube_coordinate.z > 0 else 0
		uvw = Vector3(cube_coordinate.x, cube_coordinate.y, absr.z) * Vector3(lerp(1.0, - 1.0, negz), - 1, 1);
		offset = cell_right if negz else cell_left

	var face_uv: = Vector2(Vector2(uvw.x, uvw.y) / uvw.z + Vector2.ONE) * 0.5
	var face_size: = Vector2(1.0, 1.0) / grid_size
	var uv: = offset * face_size + face_uv * face_size;
	return [uv, offset, face_size]
