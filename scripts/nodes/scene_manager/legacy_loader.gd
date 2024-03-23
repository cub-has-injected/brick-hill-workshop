class_name WorkshopLegacyLoader
extends Node

signal scene_load_started()
signal populate_tree(scene_inst)
signal scene_load_finished()

const PRINT: = false
const CHUNK_SIZE: = 64

var _spawn_point_count: = 0

func load_legacy_scene(file:File)->void :
	var scope = Profiler.scope(self, "load_legacy_scene", [file])

	emit_signal("scene_load_started")

	var parsed_brk = parse_legacy_brk(file)

	if PRINT:
		print_debug("%s Creating Set Root" % [get_name()])

	var filename = file.get_path().replace("\\", "/").split("/")[ - 1].split(".")[0]

	var set_root = SetRoot.new()
	set_root.name = filename

	if PRINT:
		print_debug("%s Creating Environment" % [get_name()])

	var brick_hill_environment = BrickHillEnvironmentGen.new()
	brick_hill_environment.name = "BrickHillEnvironment"
	brick_hill_environment.set_sky_color(parsed_brk.sky_color)
	brick_hill_environment.set_horizon_upper_color(lerp(parsed_brk.sky_color, brick_hill_environment.ground_color, 0.4))
	brick_hill_environment.set_horizon_lower_color(lerp(parsed_brk.sky_color, brick_hill_environment.ground_color, 0.6))
	brick_hill_environment.set_sun_latitude(90)
	brick_hill_environment.set_ambient_light_energy(parsed_brk.sun_intensity / 400.0)
	set_root.add_child(brick_hill_environment)
	brick_hill_environment.set_owner(set_root)

	emit_signal("populate_tree", set_root)

	_spawn_point_count = 0
	for i in range(0, (parsed_brk.entries.size() / CHUNK_SIZE) + 1):
		var from = i * CHUNK_SIZE
		var to = min(i * CHUNK_SIZE + CHUNK_SIZE, parsed_brk.entries.size())

		if PRINT:
			print_debug("%s Loading entries %s-%s" % [get_name(), from, to])

		load_legacy_brk_subset(parsed_brk.entries, set_root, from, to)
		yield (get_tree(), "idle_frame")

	if PRINT:
		print_debug("%s Scene loaded" % [get_name()])

	var dir = Directory.new()
	var legacy_backups_dir = "user://backups/legacy/"
	var make_backup_dir_error = dir.make_dir_recursive(legacy_backups_dir)
	if make_backup_dir_error:
		printerr("Error creating legacy backup directory: %s", BrickHillUtil.get_error_string(make_backup_dir_error))
		return 

	var legacy_backup_path = legacy_backups_dir + filename + ".brk"

	var backup_error = dir.copy(file.get_path(), legacy_backup_path)
	if backup_error:
		printerr("Error backing up legacy BRK file: %s", BrickHillUtil.get_error_string(backup_error))
		return 

	emit_signal("scene_load_finished")

func load_legacy_brk_subset(entries:Array, parent:Node, start:int, end:int)->void :
	var scope = Profiler.scope(self, "load_legacy_brk_subset", [entries, parent, start, end])

	for i in range(start, end):
		if PRINT:
			print_debug("%s Creating brick for entry %s" % [get_name(), i])

		var entry = entries[i]
		var bricks: = create_bricks(entry)
		for brick in bricks:
			parent.add_child(brick, true)

func create_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_bricks", [entry])

	for i in range(0, 3):
		entry.size[i] = max(entry.size[i], 0.001)

	var bricks: = []

	match entry.shape:
		"spawnpoint":
			bricks = create_spawn_point(entry)
		"cube":
			bricks = create_cube_bricks(entry)
		"cylinder":
			bricks = create_cylinder_bricks(entry)
		"wedge":
			bricks = create_wedge_bricks(entry)
		"slope":
			bricks = create_slope_bricks(entry)
		"dome":
			bricks = create_dome_bricks(entry)
		"pole":
			bricks = create_pole_bricks(entry)
		"flag":
			bricks = create_flag_bricks(entry)
		"bars":
			bricks = create_bars_bricks(entry)
		"vent":
			bricks = create_vent_bricks(entry)
		"arch":
			bricks = create_arch_bricks(entry)

	if "name" in entry:
		if entry.name == "baseplate":
			for brick in bricks:
				brick.locked = true

	return bricks

func create_spawn_point(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_spawn_point", [entry])

	_spawn_point_count += 1

	var brick = spawn_brick_object()
	brick.name = "Brick"
	brick.shape = ModelManager.BrickMeshType.CUBE
	brick.anchored = true

	setup_brick_surfaces(brick)

	scale_brick(entry, brick)

	setup_brick_color(entry, brick)

	var spawn_point = BrickHillSpawnPoint.new()
	spawn_point.name = "SpawnPoint%s" % [_spawn_point_count]
	spawn_point.transform.origin = Vector3.UP * 3.1

	var spawn_point_group = BrickHillGroup.new()
	spawn_point_group.add_child(brick)
	spawn_point_group.add_child(spawn_point)

	translate_brick(entry, spawn_point_group)
	spawn_point_group.rotation_degrees.y = entry.rotation + 180
	setup_brick_name(entry, spawn_point_group)

	return [spawn_point_group]

func create_cube_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_cube_bricks", [entry])

	var brick = spawn_brick_object()
	brick.shape = ModelManager.BrickMeshType.CUBE
	brick.anchored = true

	setup_brick_surfaces(brick)

	translate_brick(entry, brick)

	if fmod(entry.rotation, 90) != 0:
		brick.rotation_degrees = Vector3(0, entry.rotation - 90, 0)

	scale_brick(entry, brick)

	setup_brick_color(entry, brick)
	setup_brick_name(entry, brick)

	return [brick]

func create_cylinder_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_cylinder_bricks", [entry])

	var brick = spawn_brick_object()
	brick.shape = ModelManager.BrickMeshType.CYLINDER
	brick.anchored = true
	setup_brick_surfaces(brick)

	translate_brick(entry, brick)
	scale_brick(entry, brick)
	setup_brick_color(entry, brick)
	setup_brick_name(entry, brick)
	return [brick]

func create_wedge_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_wedge_bricks", [entry])

	var wedge_glue = spawn_glue_object()

	var wedge_brick = spawn_brick_object()
	wedge_brick.name = "Wedge"
	wedge_brick.shape = ModelManager.BrickMeshType.WEDGE
	setup_flat_surfaces(wedge_brick)
	wedge_brick.surfaces[4] = BrickHillBrickObject.SurfaceType.SMOOTH

	var cap_brick = spawn_brick_object()
	cap_brick.name = "Cap"
	cap_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(cap_brick)
	cap_brick.surfaces[0] = BrickHillBrickObject.SurfaceType.STUDDED
	cap_brick.surfaces[1] = BrickHillBrickObject.SurfaceType.INLETS
	cap_brick.surfaces[3] = BrickHillBrickObject.SurfaceType.SMOOTH

	wedge_brick.rotation_degrees = Vector3(0, entry.rotation + 90, - 90)

	var u_axis = fmod(entry.rotation, 180) == 0
	var foo = entry.rotation > 0 and entry.rotation < 270
	if u_axis:
		wedge_brick.size = Vector3(entry.size.y, entry.size.z, entry.size.x)
		cap_brick.size = entry.size
		wedge_brick.size.z -= 1.0
		cap_brick.size.x = 1.0

		wedge_brick.transform.origin.x += 0.5 * ( - 1.0 if foo else 1.0)
		cap_brick.transform.origin -= cap_brick.transform.basis.x.normalized() * entry.size[0 if u_axis else 2] * 0.5 * ( - 1.0 if foo else 1.0)
		cap_brick.transform.origin += cap_brick.transform.basis.x.normalized() * 0.5 * ( - 1.0 if foo else 1.0)
	else :
		wedge_brick.size = Vector3(entry.size.y, entry.size.x, entry.size.z)
		cap_brick.size = entry.size
		wedge_brick.size.z -= 1.0
		cap_brick.size.z = 1.0

		wedge_brick.transform.origin.z += 0.5 * ( - 1.0 if foo else 1.0)
		cap_brick.transform.origin -= cap_brick.transform.basis.z.normalized() * entry.size[0 if u_axis else 2] * 0.5 * ( - 1.0 if foo else 1.0)
		cap_brick.transform.origin += cap_brick.transform.basis.z.normalized() * 0.5 * ( - 1.0 if foo else 1.0)

	setup_brick_color(entry, wedge_brick)
	setup_brick_color(entry, cap_brick)

	wedge_glue.add_child(wedge_brick)
	wedge_glue.add_child(cap_brick)
	translate_brick(entry, wedge_glue)
	setup_brick_name(entry, wedge_glue)

	return [wedge_glue]

func create_slope_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_slope_bricks", [entry])

	var slope_glue = spawn_glue_object()

	var base_brick = spawn_brick_object()
	base_brick.name = "Base"
	base_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(base_brick)
	base_brick.surfaces[1] = BrickHillBrickObject.SurfaceType.INLETS

	scale_brick(entry, base_brick)

	base_brick.transform.origin += Vector3.DOWN * (entry.size.y * 0.5)
	base_brick.transform.origin += Vector3.UP * 0.25 * 0.5
	base_brick.size.y = 0.25

	setup_brick_color(entry, base_brick)

	var slope_brick = spawn_brick_object()
	slope_brick.name = "Slope"
	slope_brick.shape = ModelManager.BrickMeshType.WEDGE
	setup_flat_surfaces(slope_brick)
	slope_brick.surfaces[4] = BrickHillBrickObject.SurfaceType.SMOOTH

	var cap_brick = spawn_brick_object()
	cap_brick.name = "Cap"
	cap_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(cap_brick)
	cap_brick.surfaces[0] = BrickHillBrickObject.SurfaceType.STUDDED

	rotate_brick(entry, slope_brick)
	rotate_brick(entry, cap_brick)

	var u_axis = fmod(entry.rotation, 180) == 0
	if u_axis:
		slope_brick.size = Vector3(entry.size.z, entry.size.y, entry.size.x)
		cap_brick.size = Vector3(entry.size.z, entry.size.y, entry.size.x)
	else :
		slope_brick.size = Vector3(entry.size.x, entry.size.y, entry.size.z)
		cap_brick.size = Vector3(entry.size.x, entry.size.y, entry.size.z)

	slope_brick.size.z -= 1.0
	slope_brick.size.y -= 0.25
	slope_brick.transform.origin += Vector3.UP * 0.25 * 0.5

	cap_brick.size.z = 1.0
	cap_brick.size.y -= 0.25
	cap_brick.transform.origin += Vector3.UP * 0.25 * 0.5

	slope_brick.transform.origin += slope_brick.transform.basis.z * 0.5
	cap_brick.transform.origin -= slope_brick.transform.basis.z * entry.size[0 if u_axis else 2] * 0.5
	cap_brick.transform.origin += slope_brick.transform.basis.z * 0.5

	setup_brick_color(entry, slope_brick)
	setup_brick_color(entry, cap_brick)

	slope_glue.add_child(base_brick)
	slope_glue.add_child(slope_brick)
	slope_glue.add_child(cap_brick)
	translate_brick(entry, slope_glue)
	setup_brick_name(entry, slope_glue)

	return [slope_glue]

func create_dome_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_dome_bricks", [entry])

	var hemisphere_brick = spawn_brick_object()
	hemisphere_brick.anchored = true
	hemisphere_brick.shape = ModelManager.BrickMeshType.SPHERE_HALF
	setup_flat_surfaces(hemisphere_brick)
	translate_brick(entry, hemisphere_brick)
	scale_brick(entry, hemisphere_brick)
	setup_brick_color(entry, hemisphere_brick)
	setup_brick_name(entry, hemisphere_brick)

	return [hemisphere_brick]

func create_pole_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_pole_bricks", [entry])

	var flag_glue = spawn_glue_object()

	var brick = spawn_brick_object()
	brick.name = "Pole"
	brick.shape = ModelManager.BrickMeshType.CYLINDER
	setup_flat_surfaces(brick)

	var base_brick = spawn_brick_object()
	base_brick.name = "Base"
	base_brick.shape = ModelManager.BrickMeshType.CYLINDER
	setup_brick_surfaces(base_brick)

	var top_brick = spawn_brick_object()
	top_brick.name = "Top"
	top_brick.shape = ModelManager.BrickMeshType.SPHERE_HALF
	setup_brick_surfaces(top_brick)

	rotate_brick(entry, brick)
	scale_brick(entry, brick)

	brick.size *= Vector3(0.5, 1.0, 0.5)
	brick.size.y -= 0.5

	base_brick.transform.origin += Vector3.DOWN * entry.size.y * 0.5
	base_brick.transform.origin += Vector3.UP * 0.125
	base_brick.size.y = 0.25

	top_brick.transform.origin += Vector3.UP * entry.size.y * 0.5
	top_brick.transform.origin += Vector3.DOWN * 0.125
	top_brick.size.x = 0.5
	top_brick.size.y = 0.25
	top_brick.size.z = 0.5

	setup_brick_color(entry, brick)
	setup_brick_color(entry, base_brick)
	setup_brick_color(entry, top_brick)

	flag_glue.add_child(brick)
	flag_glue.add_child(base_brick)
	flag_glue.add_child(top_brick)
	translate_brick(entry, flag_glue)
	setup_brick_name(entry, flag_glue)

	return [flag_glue]

func create_flag_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_flag_bricks", [entry])

	var flag_brick = BrickHillModel.new()
	flag_brick.anchored = true
	flag_brick.model_name = "flag"

	flag_brick.transform.origin = entry.position + entry.size * 0.5
	flag_brick.transform.origin.y -= 0.5
	print(entry.rotation)
	flag_brick.rotation_degrees.y = entry.rotation

	return [flag_brick]

func create_bars_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_bars_bricks", [entry])

	var bars_glue = spawn_glue_object()

	var base_brick = spawn_brick_object()
	base_brick.name = "Base"
	base_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_smooth_surfaces(base_brick)
	base_brick.surfaces[1] = BrickHillBrickObject.SurfaceType.INLETS

	var top_brick = spawn_brick_object()
	top_brick.name = "Top"
	top_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_smooth_surfaces(top_brick)
	top_brick.surfaces[0] = BrickHillBrickObject.SurfaceType.STUDDED

	scale_brick(entry, base_brick)
	scale_brick(entry, top_brick)

	base_brick.transform.origin += Vector3.DOWN * entry.size.y * 0.5
	base_brick.transform.origin += Vector3.UP * 0.125
	base_brick.size.y = 0.25

	top_brick.transform.origin += Vector3.UP * entry.size.y * 0.5
	top_brick.transform.origin += Vector3.DOWN * 0.125
	top_brick.size.y = 0.25

	setup_brick_color(entry, base_brick)
	setup_brick_color(entry, top_brick)

	bars_glue.add_child(base_brick)
	bars_glue.add_child(top_brick)

	var steps = max(entry.size.x, entry.size.z)
	for i in range(0, steps):
		var bar_base_brick = spawn_brick_object()
		bar_base_brick.name = "BarBase"
		bar_base_brick.shape = ModelManager.BrickMeshType.CYLINDER
		setup_flat_surfaces(bar_base_brick)

		rotate_brick(entry, bar_base_brick)
		scale_brick(entry, bar_base_brick)
		bar_base_brick.size.x = 0.8
		bar_base_brick.size.y = 0.25
		bar_base_brick.size.z = 0.8
		bar_base_brick.transform.origin += Vector3.DOWN * entry.size.y * 0.5
		bar_base_brick.transform.origin += Vector3.UP * 0.375

		var dir = bar_base_brick.transform.basis.x
		bar_base_brick.transform.origin -= dir.normalized() * (steps * 0.5 - 0.5)
		bar_base_brick.transform.origin += dir.normalized() * i
		setup_brick_color(entry, bar_base_brick)
		bars_glue.add_child(bar_base_brick, true)

		var bar_brick = spawn_brick_object()
		bar_brick.name = "BarBrick"
		bar_brick.shape = ModelManager.BrickMeshType.CYLINDER
		setup_flat_surfaces(bar_brick)

		rotate_brick(entry, bar_brick)
		scale_brick(entry, bar_brick)
		bar_brick.size.x = 0.5
		bar_brick.size.y -= 0.75
		bar_brick.size.z = 0.5
		bar_brick.transform.origin += Vector3.UP * 0.125
		bar_brick.transform.origin += dir.normalized() * (steps * 0.5 - 0.5)
		bar_brick.transform.origin -= dir.normalized() * i
		setup_brick_color(entry, bar_brick)
		bars_glue.add_child(bar_brick, true)

	translate_brick(entry, bars_glue)
	setup_brick_name(entry, bars_glue)

	return [bars_glue]

func create_vent_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_vent_bricks", [entry])

	var vent_glue = spawn_glue_object()

	var base_brick = spawn_brick_object()
	base_brick.name = "Base"
	base_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(base_brick)

	scale_brick(entry, base_brick)

	base_brick.transform.origin += Vector3.DOWN * (entry.size.y * 0.5)
	base_brick.transform.origin += Vector3.UP * 0.125 * 0.5
	base_brick.size.y = 0.125

	setup_brick_color(entry, base_brick)

	vent_glue.add_child(base_brick)

	var u_axis: = fmod(entry.rotation, 180) == 0
	var steps = entry.size.x if u_axis else entry.size.z
	for i in range(0, steps):
		for o in [ - 1, 0, 1]:
			var bar_brick = spawn_brick_object()
			bar_brick.name = "Bar"
			bar_brick.shape = ModelManager.BrickMeshType.CUBE

			scale_brick(entry, bar_brick)
			var size_u = 0.1875
			if u_axis:
				bar_brick.size.x = size_u
			else :
				bar_brick.size.z = size_u

			bar_brick.size.y = size_u
			bar_brick.transform.origin += Vector3.UP * entry.size.y * 0.5
			bar_brick.transform.origin += Vector3.DOWN * size_u * 0.5

			var repeat_axis = bar_brick.transform.basis.x.normalized() if u_axis else - bar_brick.transform.basis.z.normalized()
			bar_brick.transform.origin -= repeat_axis * (steps * 0.5 - 0.5)
			bar_brick.transform.origin += repeat_axis * o * 1.3 * (0.5 - size_u)
			bar_brick.transform.origin += repeat_axis * i

			setup_brick_color(entry, bar_brick)
			vent_glue.add_child(bar_brick, true)

	translate_brick(entry, vent_glue)
	setup_brick_name(entry, vent_glue)

	return [vent_glue]

func create_arch_bricks(entry:Dictionary)->Array:
	var scope = Profiler.scope(self, "create_arch_bricks", [entry])

	var arch_glue = spawn_glue_object()

	var top_brick = spawn_brick_object()
	top_brick.name = "Top"
	top_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(top_brick)
	top_brick.surfaces[0] = BrickHillBrickObject.SurfaceType.STUDDED

	scale_brick(entry, top_brick)

	top_brick.transform.origin += Vector3.UP * (entry.size.y * 0.5)
	top_brick.transform.origin += Vector3.DOWN * 0.25
	top_brick.size.y = 0.5

	setup_brick_color(entry, top_brick)

	var u_axis: = fmod(entry.rotation, 180) == 0
	var repeat_axis = Vector3.FORWARD if u_axis else Vector3.RIGHT
	var axis_size = entry.size.z if u_axis else entry.size.x

	var left_brick = spawn_brick_object()
	left_brick.name = "Left"
	left_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(left_brick)
	left_brick.surfaces[1] = BrickHillBrickObject.SurfaceType.INLETS

	scale_brick(entry, left_brick)

	if u_axis:
		left_brick.size.z = 1.0
	else :
		left_brick.size.x = 1.0

	left_brick.size.y -= 0.5
	left_brick.transform.origin -= repeat_axis * (axis_size * 0.5 - 0.5)
	left_brick.transform.origin += Vector3.DOWN * 0.25
	setup_brick_color(entry, left_brick)

	var right_brick = spawn_brick_object()
	right_brick.name = "Right"
	right_brick.shape = ModelManager.BrickMeshType.CUBE
	setup_flat_surfaces(right_brick)
	right_brick.surfaces[1] = BrickHillBrickObject.SurfaceType.INLETS

	scale_brick(entry, right_brick)

	if u_axis:
		right_brick.size.z = 1.0
	else :
		right_brick.size.x = 1.0

	right_brick.size.y -= 0.5
	right_brick.transform.origin += repeat_axis * (axis_size * 0.5 - 0.5)
	right_brick.transform.origin += Vector3.DOWN * 0.25
	setup_brick_color(entry, right_brick)

	var arch_brick = spawn_brick_object()
	arch_brick.name = "Arch"
	arch_brick.shape = ModelManager.BrickMeshType.INVERSE_CYLINDER_HALF
	setup_brick_surfaces(arch_brick)

	arch_brick.rotation_degrees = Vector3(0, entry.rotation, - 90)
	if u_axis:
		arch_brick.size = Vector3(entry.size.y - 0.5, entry.size.x, entry.size.z - 2.0)
	else :
		arch_brick.size = Vector3(entry.size.y - 0.5, entry.size.z, entry.size.x - 2.0)
	arch_brick.transform.origin.y -= 0.25

	setup_brick_color(entry, arch_brick)

	arch_glue.add_child(arch_brick)
	arch_glue.add_child(top_brick)
	arch_glue.add_child(left_brick)
	arch_glue.add_child(right_brick)
	translate_brick(entry, arch_glue)
	setup_brick_name(entry, arch_glue)

	return [arch_glue]

func spawn_glue_object()->BrickHillBrickObject:
	var scope = Profiler.scope(self, "spawn_glue_object", [])

	var glue_object = BrickHillGlue.new()
	glue_object.anchored = true
	return glue_object

func spawn_brick_object()->BrickHillBrickObject:
	var scope = Profiler.scope(self, "spawn_brick_object", [])

	var brick_object = BrickHillBrickObject.new()
	return brick_object

func setup_brick_name(entry:Dictionary, brick:BrickHillObject)->void :
	var scope = Profiler.scope(self, "setup_brick_name", [entry, brick])

	if "name" in entry:
		brick.name = entry.name

func setup_brick_color(entry:Dictionary, brick:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "setup_brick_color", [entry, brick])

	var colors: = PoolColorArray()
	for _i in range(0, ModelManager.get_brick_mesh_surface_count(brick.shape)):
		colors.append(entry.color)
	brick.colors = colors
	brick.opacity = entry.color.a
	if entry.color.a < 1.0:
		brick.roughness = 0.0

	if entry.color.a == 0:
		brick.visible = false

	if "light_color" in entry:
		brick.light_color = entry.light_color
		brick.light_range = entry.light_range
		brick.light_energy = 1

func setup_flat_surfaces(brick:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "setup_flat_surfaces", [brick])

	var surfaces = []
	for _i in range(0, ModelManager.get_brick_mesh_surface_count(brick.shape)):
		surfaces.append(BrickHillBrickObject.SurfaceType.FLAT)
	brick.surfaces = surfaces

func setup_smooth_surfaces(brick:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "setup_smooth_surfaces", [brick])

	var surfaces = []
	for _i in range(0, ModelManager.get_brick_mesh_surface_count(brick.shape)):
		surfaces.append(BrickHillBrickObject.SurfaceType.SMOOTH)
	brick.surfaces = surfaces

func setup_brick_surfaces(brick:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "setup_brick_surfaces", [brick])

	match brick.shape:
		ModelManager.BrickMeshType.CUBE:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.STUDDED, 
				BrickHillBrickObject.SurfaceType.INLETS, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
			]
		ModelManager.BrickMeshType.CYLINDER:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH
			]
		ModelManager.BrickMeshType.CYLINDER_HALF:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
			]
		ModelManager.BrickMeshType.CYLINDER_QUARTER:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
			]
		ModelManager.BrickMeshType.INVERSE_CYLINDER_HALF:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
			]
		ModelManager.BrickMeshType.INVERSE_CYLINDER_QUARTER:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
				BrickHillBrickObject.SurfaceType.SMOOTH, 
			]
		ModelManager.BrickMeshType.SPHERE:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]
		ModelManager.BrickMeshType.SPHERE_HALF:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]
		ModelManager.BrickMeshType.SPHERE_QUARTER:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]
		ModelManager.BrickMeshType.SPHERE_EIGTH:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]
		ModelManager.BrickMeshType.WEDGE:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]
		ModelManager.BrickMeshType.WEDGE_CORNER:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]
		ModelManager.BrickMeshType.WEDGE_EDGE:
			brick.surfaces = [
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
				BrickHillBrickObject.SurfaceType.FLAT, 
			]

func transform_brick(entry:Dictionary, brick:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "transform_brick", [entry, brick])

	translate_brick(entry, brick)
	rotate_brick(entry, brick)
	scale_brick(entry, brick)

func translate_brick(entry:Dictionary, brick:BrickHillObject)->void :
	var scope = Profiler.scope(self, "translate_brick", [entry, brick])

	brick.transform.origin = entry.position + entry.size * 0.5

func rotate_brick(entry:Dictionary, brick:BrickHillObject)->void :
	var scope = Profiler.scope(self, "rotate_brick", [entry, brick])

	brick.rotation_degrees.y = entry.rotation - 90

func scale_brick(entry:Dictionary, brick:BrickHillBrickObject)->void :
	var scope = Profiler.scope(self, "scale_brick", [entry, brick])

	brick.size = entry.size

func parse_legacy_brk(file:File)->Dictionary:
	var scope = Profiler.scope(self, "parse_legacy_brk", [file])

	if PRINT:
		print_debug("%s Parsing legacy .brk %s" % [get_name(), file])

	var entries: = []

	
	file.get_line()

	
	var line:String
	var comps:PoolStringArray

	line = file.get_line()
	comps = line.split(" ")

	line = file.get_line()
	comps = line.split(" ")
	var baseplate_color = Color(
		comps[2].to_float(), 
		comps[1].to_float(), 
		comps[0].to_float(), 
		comps[3].to_float()
	)

	line = file.get_line()
	comps = line.split(" ")
	var sky_color = Color(
		comps[0].to_float(), 
		comps[1].to_float(), 
		comps[2].to_float(), 
		1.0
	)

	var baseplate_size_scalar = file.get_line().to_float()
	var baseplate_position = Vector3( - baseplate_size_scalar * 0.5, - 1.0, - baseplate_size_scalar * 0.5)
	var baseplate_size = Vector3(baseplate_size_scalar, 1.0, baseplate_size_scalar)

	var sun_intensity = file.get_line().to_float()

	entries.append({
		"name":"baseplate", 
		"position":baseplate_position, 
		"size":baseplate_size, 
		"color":baseplate_color
	})

	if PRINT:
		print_debug("%s Ambient Light Color: %s, Sky Color: %s, Sun Intensity: %s" % [get_name(),  sky_color, sun_intensity])
		print_debug("%s Baseplate Size: %s, Baseplate Color: %s" % [get_name(), baseplate_size_scalar, baseplate_color])

	
	file.get_line()

	var i: = 0;
	while not file.eof_reached():
		if PRINT:
			print_debug("%s reading line %s" % [get_name(), i])
		i += 1

		line = file.get_line()
		if line.substr(0, 1) == "	":
			comps = line.substr(2).split(" ")
			var key = comps[0]
			comps.remove(0)

			var value = comps.join(" ")

			match key:
				"NAME":
					entries[ - 1]["name"] = value
				"ROT":
					entries[ - 1]["rotation"] = value.to_float()
				"SHAPE":
					match value:
						"plate":
							entries[ - 1]["shape"] = "cube"
						"spawnpoint":
							entries[ - 1]["shape"] = "spawnpoint"
						"cylinder":
							entries[ - 1]["shape"] = "cylinder"
						"slope":
							entries[ - 1]["shape"] = "slope"
						"wedge":
							entries[ - 1]["shape"] = "wedge"
						"dome":
							entries[ - 1]["shape"] = "dome"
						"pole":
							entries[ - 1]["shape"] = "pole"
						"flag":
							entries[ - 1]["shape"] = "flag"
						"bars":
							entries[ - 1]["shape"] = "bars"
						"vent":
							entries[ - 1]["shape"] = "vent"
						"arch":
							entries[ - 1]["shape"] = "arch"
						_:
							print_debug("Warning: Unhandled shape %s" % [value])
				"LIGHT":
					entries[ - 1]["light_color"] = Color(comps[0].to_float(), comps[1].to_float(), comps[2].to_float())
					entries[ - 1]["light_range"] = comps[3].to_float()
				_:
					print_debug("Warning: Unrecognized key %s" % [key])
		else :
			if line == "" or line.substr(0, 1) == ">":
				continue

			comps = line.split(" ")

			var position = Vector3(
				comps[0].to_float(), 
				comps[2].to_float(), 
				comps[1].to_float()
			)

			var size = Vector3(
				comps[3].to_float(), 
				comps[5].to_float(), 
				comps[4].to_float()
			)

			var color = Color(
				comps[6].to_float(), 
				comps[7].to_float(), 
				comps[8].to_float(), 
				comps[9].to_float()
			)

			entries.append({
				"position":position, 
				"size":size, 
				"color":color
			})

	for j in range(0, entries.size()):
		if not "shape" in entries[j]:
			entries[j]["shape"] = "cube"
		if not "rotation" in entries[j]:
			entries[j]["rotation"] = 0.0

	return {
		##"ambient_light_color":ambient_light_color, 
		"sky_color":sky_color, 
		"sun_intensity":sun_intensity, 
		"entries":entries
	}

func _ready():
	var file = File.new()
	file.open("user://assets/maps/ccc.brk", File.READ)
	parse_legacy_brk(file)
