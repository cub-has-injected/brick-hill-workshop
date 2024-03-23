class_name WorkshopSceneManager
extends Node

const LEGACY_BRK_HEADER = "B R I C K  W O R K S H O P  V0.2.0.0"

signal show_save_as_dialog()

signal scene_saved()
signal scene_load_started()
signal scene_load_finished()
signal scene_load_failed(title, message)
signal scene_unloaded()

signal spawn_points_changed(spawn_points)
signal primary_spawn_changed(index)

var scene_path:String setget set_scene_path
var dir = Directory.new()

var _loaded_scene_path:String
var _update_loaded_scene:bool = true

func set_scene_path(new_scene_path:String)->void :
	var scope = Profiler.scope(self, "set_scene_path", [new_scene_path])

	if scene_path != new_scene_path:
		scene_path = new_scene_path
		if scene_path.empty():
			OS.set_window_title("Brick Hill")
		else :
			OS.set_window_title("Brick Hill - %s" % [scene_path])

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	var temp_dir = BrickHillUtil.TEMP_DIR

	if dir.dir_exists(temp_dir):
		
		
		pass
	else :
		
		dir.make_dir_recursive(temp_dir)

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	var temp_dir = BrickHillUtil.TEMP_DIR

	
	if dir.dir_exists(temp_dir):
		if dir.open(temp_dir) == OK:
			dir.list_dir_begin(true, false)
			while true:
				var file = dir.get_next()
				if file != "":
					dir.remove(file)
				else :
					dir.list_dir_end()
					break

			dir.remove(temp_dir)

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	call_deferred("new_scene")

func new_scene()->void :
	var scope = Profiler.scope(self, "new_scene", [])

	var set_root_container = WorkshopDirectory.set_root_container()
	if not set_root_container:
		return 

	scene_load_started()

	var new_set_root = SetRoot.new()
	new_set_root.name = "SetRoot"

	var brick_hill_environment = BrickHillEnvironmentGen.new()
	brick_hill_environment.name = "BrickHillEnvironment"
	new_set_root.add_child(brick_hill_environment)
	brick_hill_environment.set_owner(new_set_root)

	var baseplate_brick = BrickHillBrickObject.new()
	baseplate_brick.translation = Vector3(0.0, - 0.5, 0.0)
	baseplate_brick.name = "Baseplate"
	baseplate_brick.size = Vector3(48, 1, 48)
	baseplate_brick.albedo = Color.black
	baseplate_brick.locked = true
	baseplate_brick.anchored = true
	new_set_root.add_child(baseplate_brick)

	populate_tree(new_set_root)
	emit_signal("scene_load_finished")

	baseplate_brick.call_deferred("set_surfaces", [
		BrickHillBrickObject.SurfaceType.STUDDED, 
		BrickHillBrickObject.SurfaceType.INLETS, 
		BrickHillBrickObject.SurfaceType.SMOOTH, 
		BrickHillBrickObject.SurfaceType.SMOOTH, 
		BrickHillBrickObject.SurfaceType.SMOOTH, 
		BrickHillBrickObject.SurfaceType.SMOOTH, 
	])

	set_scene_path("")

func load_scene(path:String, update_scene_path:bool = true, update_recent_files:bool = true)->void :
	var scope = Profiler.scope(self, "load_scene", [path, update_scene_path, update_recent_files])

	if not dir.file_exists(path):
		return 

	var file = File.new()
	var open_error = file.open(path, File.READ)
	if open_error:
		printerr("Error opening file: %s" % BrickHillUtil.get_error_string(open_error))
		return 

	_loaded_scene_path = path
	_update_loaded_scene = update_scene_path

	if update_recent_files:
		WorkshopSettings.data.add_recent_file(path)

	if file.get_line() == LEGACY_BRK_HEADER:
		$LegacyLoader.load_legacy_scene(file)
	else :
		$SceneLoader.load_godot_scene(path)

func clear_tree()->void :
	var scope = Profiler.scope(self, "clear_tree", [])

	var set_root_container = WorkshopDirectory.set_root_container()
	if not set_root_container:
		return 

	var set_root = WorkshopDirectory.set_root()
	if set_root:
		assert (
			set_root.is_connected("spawn_points_changed", self, "_spawn_points_changed") and 
			set_root.is_connected("primary_spawn_changed", self, "_primary_spawn_changed")
		)
		set_root.disconnect("spawn_points_changed", self, "_spawn_points_changed")
		set_root.disconnect("primary_spawn_changed", self, "_primary_spawn_changed")
		set_root_container.remove_child(set_root)
		set_root.queue_free()

	emit_signal("scene_unloaded")

func populate_tree(loaded_set_root:SetRoot)->void :
	var scope = Profiler.scope(self, "populate_tree", [loaded_set_root])

	var set_root_container = WorkshopDirectory.set_root_container()
	if not set_root_container:
		return 

	loaded_set_root.connect("spawn_points_changed", self, "_spawn_points_changed")
	loaded_set_root.connect("primary_spawn_changed", self, "_primary_spawn_changed")

	loaded_set_root.set_workshop(true)

	set_root_container.add_child(loaded_set_root)

func save_scene()->void :
	var scope = Profiler.scope(self, "save_scene", [])

	if scene_path == "":
		emit_signal("show_save_as_dialog")
		return 

	save_scene_as(scene_path)

func save_scene_as(path:String)->void :
	var scope = Profiler.scope(self, "save_scene_as", [path])

	if path == "":
		return 

	set_scene_path(path)

	var set_root = WorkshopDirectory.set_root()
	if not is_instance_valid(set_root):
		return 

	for child in set_root.get_children():
		set_owners_recursive(set_root, child)

	var packed_scene = PackedScene.new()
	var pack_error = packed_scene.pack(set_root)
	if pack_error:
		printerr("Error packing scene: %s" % [pack_error])
		return 

	var target_path = BrickHillUtil.get_temp_file_for_path(scene_path)

	
	var save_error = ResourceSaver.save(target_path, packed_scene, ResourceSaver.FLAG_COMPRESS)
	if save_error:
		printerr("Error saving scene: %s" % BrickHillUtil.get_error_string(save_error))
		return 

	
	var dir = Directory.new()
	var backup_dir = "user://backups/%s/" % [set_root.uuid]
	var mkdir_error = dir.make_dir_recursive(backup_dir)
	if mkdir_error:
		printerr("Error saving scene: %s" % BrickHillUtil.get_error_string(mkdir_error))
		return 

	var backup_path = backup_dir + "%s-%s.brk" % [OS.get_unix_time(), OS.get_ticks_msec()]
	var backup_error = dir.copy(scene_path, backup_path)
	if backup_error:
		printerr("Error saving scene: %s" % BrickHillUtil.get_error_string(backup_error))

	
	var copy_error = dir.copy(target_path, scene_path)
	if copy_error:
		printerr("Error saving scene: %s" % BrickHillUtil.get_error_string(copy_error))
		return 

	emit_signal("scene_saved")

func set_owners_recursive(owner:Node, node:Node)->void :
	var scope = Profiler.scope(self, "set_owners_recursive", [owner, node])

	if node is BrickHillObject:
		node.set_owner(owner)

	for child in node.get_children():
		set_owners_recursive(owner, child)

func scene_load_failed(title, message)->void :
	var scope = Profiler.scope(self, "scene_load_failed", [title, message])

	_loaded_scene_path = ""
	emit_signal("scene_load_failed", title, message)

func _spawn_points_changed(spawn_points:Array)->void :
	var scope = Profiler.scope(self, "_spawn_points_changed", [spawn_points])

	emit_signal("spawn_points_changed", spawn_points)

func _primary_spawn_changed(index:int)->void :
	var scope = Profiler.scope(self, "_primary_spawn_changed", [index])

	emit_signal("primary_spawn_changed", index)


func scene_load_started()->void :
	var scope = Profiler.scope(self, "scene_load_started", [])

	emit_signal("scene_load_started")
	clear_tree()

func scene_load_finished()->void :
	var scope = Profiler.scope(self, "scene_load_finished", [])

	if _update_loaded_scene:
		set_scene_path(_loaded_scene_path)
	_loaded_scene_path = ""
	emit_signal("scene_load_finished")
