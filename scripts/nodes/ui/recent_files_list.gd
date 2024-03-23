class_name RecentFilesList
extends VBoxContainer

signal load_scene(path)

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	WorkshopSettings.data.connect("recent_files_changed", self, "on_recent_files_changed")
	on_recent_files_changed()

func on_recent_files_changed()->void :
	var scope = Profiler.scope(self, "on_recent_files_changed", [])

	for child in get_children():
		if child.has_meta("recent_files_list_child"):
			remove_child(child)
			child.queue_free()

	var recent_files = WorkshopSettings.data.get_recent_files()
	for i in range(recent_files.size() - 1, - 1, - 1):
		var path = recent_files[i]
		var button = Button.new()
		button.text = path
		button.clip_text = true
		button.align = Button.ALIGN_LEFT
		button.set_meta("recent_files_list_child", true)
		button.connect("pressed", self, "on_button_pressed", [path])
		add_child(button)

func on_button_pressed(path:String)->void :
	var scope = Profiler.scope(self, "on_button_pressed", [path])

	emit_signal("load_scene", path)

func set_disabled(new_disabled:bool)->void :
	var scope = Profiler.scope(self, "set_disabled", [new_disabled])

	for node in get_children():
		node.set_disabled(new_disabled)
