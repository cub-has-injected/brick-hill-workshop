class_name WorkshopSettingsData
extends Resource

signal recent_files_changed()

export (int) var max_recent_files: = 10
export (PoolStringArray) var recent_files: = PoolStringArray() setget , get_recent_files

export (int) var max_backups: = 10

func get_recent_files()->PoolStringArray:
	var scope = Profiler.scope(self, "get_recent_files", [])

	
	var dir = Directory.new()
	for i in range(recent_files.size() - 1, - 1, - 1):
		if not dir.file_exists(recent_files[i]):
			recent_files.remove(i)

	return recent_files

func add_recent_file(path:String)->void :
	var scope = Profiler.scope(self, "add_recent_file", [path])

	
	for i in range(recent_files.size() - 1, - 1, - 1):
		if recent_files[i] == path:
			recent_files.remove(i)

	recent_files.append(path)

	while recent_files.size() > max_recent_files:
		recent_files.remove(0)

	emit_signal("recent_files_changed")
	emit_signal("changed")
