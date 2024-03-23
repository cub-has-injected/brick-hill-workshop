class_name BackupsList
extends VBoxContainer

signal load_scene(path, update_scene_path, update_recent_files)

var _uuid:String = ""

func on_scene_loaded()->void :
	var scope = Profiler.scope(self, "on_scene_loaded", [])

	var set_root = WorkshopDirectory.set_root()
	var new_uuid = set_root.uuid
	if _uuid == new_uuid:
		return 

	_uuid = new_uuid

	clear_list()
	populate_list()

func on_scene_saved()->void :
	var scope = Profiler.scope(self, "on_scene_saved", [])

	clear_list()
	populate_list()

func clear_list()->void :
	var scope = Profiler.scope(self, "clear_list", [])

	for child in get_children():
		if child.has_meta("backup_list_child"):
			remove_child(child)
			child.queue_free()

func populate_list()->void :
	var scope = Profiler.scope(self, "populate_list", [])

	var dir = Directory.new()
	var backups_dir = "user://backups/%s/" % [_uuid]
	var open_error = dir.open(backups_dir)
	if open_error:
		print("No backup directory for current scene")
		return 

	var list_dir_error = dir.list_dir_begin(true)
	if list_dir_error:
		printerr("Failed to list backup directory")
		return 

	var backups: = []

	var button_group = ButtonGroup.new()

	var file = File.new()
	while true:
		var filename = dir.get_next()
		if filename.empty():
			break
		var modified_time = file.get_modified_time(backups_dir + filename)
		print("File %s last modified at %s" % [filename, modified_time])
		backups.append([filename, modified_time])

	backups.sort_custom(self, "sort_last_modified")

	while backups.size() > WorkshopSettings.data.max_backups:
		var backup = backups[backups.size() - 1]
		backups.remove(backups.size() - 1)
		var filename = backup[0]
		print("Removing old backup %s" % [backups_dir + filename])
		dir.remove(backups_dir + filename)

	var current_scene_path = WorkshopDirectory.scene_manager().scene_path
	var current_button = Button.new()
	current_button.text = "Latest"
	current_button.clip_text = true
	current_button.align = Button.ALIGN_LEFT
	current_button.toggle_mode = true
	current_button.pressed = true
	current_button.group = button_group
	current_button.set_meta("backup_list_child", true)
	current_button.connect("pressed", self, "on_button_pressed", [current_scene_path])
	add_child(current_button)

	for backup in backups:
		var filename = backup[0]
		var last_modified = backup[1]
		var date = OS.get_datetime_from_unix_time(last_modified)

		var button = Button.new()
		button.text = "%02d:%02d:%02d - %02d/%02d/%04d" % [date.hour, date.minute, date.second, date.day, date.month, date.year]
		button.clip_text = true
		button.align = Button.ALIGN_LEFT
		button.toggle_mode = true
		button.group = button_group
		button.set_meta("backup_list_child", true)
		button.connect("pressed", self, "on_button_pressed", [backups_dir + filename])
		add_child(button)

func sort_last_modified(lhs:Array, rhs:Array)->bool:
	var scope = Profiler.scope(self, "sort_last_modified", [lhs, rhs])

	return lhs[1] > rhs[1]

func on_button_pressed(path:String)->void :
	var scope = Profiler.scope(self, "on_button_pressed", [path])

	emit_signal("load_scene", path, false, false)

func set_disabled(new_disabled:bool)->void :
	var scope = Profiler.scope(self, "set_disabled", [new_disabled])

	for node in get_children():
		node.set_disabled(new_disabled)
