class_name WavefrontObj
extends Resource
tool 

signal cleared()


class BaseGeometry:
	var groups:PoolStringArray
	var smoothing_group: = 0
	var merging_group: = 0
	var merging_resolution: = 0.0
	var material: = ""

	func _init()->void :
		var scope = Profiler.scope(self, "_init", [])

		groups = []

class PointGeometry extends BaseGeometry:
	var vertex_indices: = PoolIntArray()

class LineGeometry extends PointGeometry:
	var uv_indices: = PoolIntArray()

class FaceGeometry extends LineGeometry:
	var normal_indices: = PoolIntArray()


export (bool) var reload: = false setget set_reload
export (String) var path setget set_path


var material_libraries: = PoolStringArray()

var vertices_geometric: = PoolRealArray()
var vertices_normal: = PoolVector3Array()
var vertices_texture: = PoolVector3Array()
var vertices_parameter: = PoolVector3Array()

var groups: = {"default":0}

var active_groups: = PoolStringArray(["default"])
var active_smoothing_group: = 0
var active_merging_group: = 0
var active_merging_resolution: = 0.0
var active_material: = "default"

var geometries_point: = []
var geometries_line: = []
var geometries_face: = []

var file = File.new()
var job_system:JobSystem = null
var start_ts: = - 1


func set_reload(new_reload:bool)->void :
	var scope = Profiler.scope(self, "set_reload", [new_reload])

	if new_reload:
		update_data()

func set_path(new_path:String)->void :
	var scope = Profiler.scope(self, "set_path", [new_path])

	if path != new_path:
		path = new_path


func get_groups()->Array:
	var scope = Profiler.scope(self, "get_groups", [])

	return groups.keys()

func get_unique_groups()->Array:
	var scope = Profiler.scope(self, "get_unique_groups", [])

	var unique: = []
	for group in groups:
		if groups[group] == 1:
			unique.append(group)
	if unique.size() == 0:
		return ["default"]
	return unique

func get_face_geometries_by_group(group:String)->Array:
	var scope = Profiler.scope(self, "get_face_geometries_by_group", [group])

	var filtered: = []
	for geometry_face in geometries_face:
		if group in geometry_face.groups:
			filtered.append(geometry_face)
	return filtered


func clear()->void :
	var scope = Profiler.scope(self, "clear", [])

	material_libraries = PoolStringArray()

	vertices_geometric = PoolRealArray()
	vertices_normal = PoolVector3Array()
	vertices_texture = PoolVector3Array()
	vertices_parameter = PoolVector3Array()

	groups = {"default":0}
	active_groups = ["default"]
	active_smoothing_group = 0
	active_merging_group = 0
	active_merging_resolution = 0.0
	active_material = "default"

	geometries_point = []
	geometries_line = []
	geometries_face = []

	emit_signal("cleared")

func update_data()->void :
	var scope = Profiler.scope(self, "update_data", [])

	clear()
	parse_obj_file()


func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	job_system = JobSystem.new()
	job_system.connect("jobs_finished", self, "parse_complete")


func parse_obj_file()->void :
	var scope = Profiler.scope(self, "parse_obj_file", [])

	start_ts = OS.get_ticks_msec()

	var open_error = file.open(path, File.READ)
	if open_error:
		printerr("Error opening .obj file %s: %s" % [path, open_error])
		return 

	var file_string = file.get_as_text()
	file.close()

	parse_obj_string(file_string)

func parse_obj_string(file_string:String)->void :
	var scope = Profiler.scope(self, "parse_obj_string", [file_string])

	var file_lines = file_string.split("\n", false)
	job_system.work_mode = JobSystem.WorkMode.THREADS
	job_system.run_job_single(self, "parse_obj_lines", {"file_lines":file_lines})

func parse_obj_lines(userdata:Dictionary)->void :
	var scope = Profiler.scope(self, "parse_obj_lines", [userdata])

	var job_index = userdata.job_index
	var file_lines = userdata.file_lines
	for file_line in file_lines:
		parse_file_line(file_line)
	job_system.call_deferred("job_finished", job_index)

func parse_complete(job_results:Dictionary)->void :
	var scope = Profiler.scope(self, "parse_complete", [job_results])

	print_debug("%s parse took %s msec" % [get_name(), OS.get_ticks_msec() - start_ts])
	emit_signal("changed")

func parse_file_line(line:String):
	var scope = Profiler.scope(self, "parse_file_line", [line])

	var comps = line.split(" ", false)
	var type = comps[0]
	match type:
		"o":
			parse_object_name(comps)
		"mtllib":
			parse_material_library(comps)
		"v":
			parse_vertex_geometric(comps)
		"vn":
			parse_vertex_normal(comps)
		"vp":
			parse_vertex_parameter(comps)
		"vt":
			parse_vertex_texture(comps)
		"g":
			parse_group(comps)
		"s":
			parse_smoothing_group(comps)
		"mg":
			parse_merging_group(comps)
		"usemtl":
			parse_use_material(comps)
		"p":
			parse_geometry_point(comps)
		"l":
			parse_geometry_line(comps)
		"f":
			parse_geometry_face(comps)


func parse_object_name(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_object_name", [comps])

	set_name(comps[1])

func parse_material_library(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_material_library", [comps])

	comps.remove(0)
	material_libraries.append_array(comps)


func parse_vertex_geometric(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_vertex_geometric", [comps])

	var float_comps = PoolRealArray([
		comps[1].to_float(), 
		comps[2].to_float(), 
		comps[3].to_float(), 
		comps[4].to_float() if comps.size() > 4 else 0.0
	])
	vertices_geometric.append_array(float_comps)

func parse_vertex_normal(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_vertex_normal", [comps])

	vertices_normal.append(Vector3(
		comps[1].to_float(), 
		comps[2].to_float(), 
		comps[3].to_float()
	))

func parse_vertex_texture(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_vertex_texture", [comps])

	vertices_texture.append(Vector3(
		comps[1].to_float(), 
		1.0 - comps[2].to_float(), 
		comps[3].to_float() if comps.size() > 3 else 0.0
	))

func parse_vertex_parameter(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_vertex_parameter", [comps])

	var vertex_parameter = Vector3()
	for i in range(1, comps.size()):
		vertex_parameter[i - 1] = comps[i].to_float()
	vertices_parameter.append(vertex_parameter)


func parse_group(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_group", [comps])

	comps.remove(0)
	for comp in comps:
		groups[comp] = groups[comp] + 1 if comp in groups else 1

	active_groups = comps

func parse_smoothing_group(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_smoothing_group", [comps])

	if comps[1] == "off":
		active_smoothing_group = 0
		return 

	active_smoothing_group = comps[1].to_int()

func parse_merging_group(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_merging_group", [comps])

	active_merging_group = comps[1].to_int()

func parse_use_material(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_use_material", [comps])

	active_material = comps[1]


func initialize_geometry(geometry):
	var scope = Profiler.scope(self, "initialize_geometry", [geometry])

	geometry.groups = active_groups
	geometry.smoothing_group = active_smoothing_group
	geometry.merging_group = active_merging_group
	geometry.merging_resolution = active_merging_resolution

func parse_geometry_point(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_geometry_point", [comps])

	var geometry_point: = PointGeometry.new()
	initialize_geometry(geometry_point)
	for i in range(1, comps.size()):
		geometry_point.vertex_indices.append(comps[i].to_int())
	geometries_point.append(geometry_point)

func parse_geometry_line(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_geometry_line", [comps])

	var geometry_line: = LineGeometry.new()
	initialize_geometry(geometry_line)
	for i in range(1, comps.size()):
		if not ("/" in comps[i]):
			geometry_line.vertex_indices.append(comps[i].to_int())
		else :
			var sub_comps = comps[i].split("/")
			geometry_line.vertex_indices.append(sub_comps[0].to_int())
			geometry_line.uv_indices.append(sub_comps[1].to_int())
	geometries_line.append(geometry_line)

func parse_geometry_face(comps:PoolStringArray)->void :
	var scope = Profiler.scope(self, "parse_geometry_face", [comps])

	var geometry_face: = FaceGeometry.new()
	initialize_geometry(geometry_face)

	var vertex_indices = PoolIntArray()
	var uv_indices = PoolIntArray()
	var normal_indices = PoolIntArray()

	for i in range(1, comps.size()):
		var sub_comps = comps[i].split("/")
		vertex_indices.append(sub_comps[0].to_int() - 1)
		uv_indices.append(sub_comps[1].to_int() - 1)
		normal_indices.append(sub_comps[2].to_int() - 1)

	geometry_face.vertex_indices = vertex_indices
	geometry_face.uv_indices = uv_indices
	geometry_face.normal_indices = normal_indices

	geometries_face.append(geometry_face)
