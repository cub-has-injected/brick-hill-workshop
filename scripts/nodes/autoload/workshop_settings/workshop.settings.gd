extends Node

export (Resource) var data = null

const SETTINGS_FILE = "user://workshop_settings.res"

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	print("Loading workshop settings...")

	var dir = Directory.new()
	if dir.file_exists(SETTINGS_FILE):
		data = ResourceLoader.load(SETTINGS_FILE)
	else :
		data = WorkshopSettingsData.new()

	data.connect("changed", self, "data_changed")

	print("Done.")

func data_changed()->void :
	var scope = Profiler.scope(self, "data_changed", [])

	print("Saving workshop settings...")
	ResourceSaver.save(SETTINGS_FILE, data)
	print("Done.")
