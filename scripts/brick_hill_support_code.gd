class_name BrickHillSupportCode

const UPDATER_EXECUTABLE: = "brick-hill-updater"

static func get_bin_dir()->String:
	var base_dir = get_executable_directory()
	match OS.get_name():
		"OSX":
			return base_dir
		_:
			return base_dir.plus_file("bin")

static func get_dev_bin_dir()->String:
	match OS.get_name():
		"Windows":
			return "P:/Brick Hill/game/support_code/target/x86_64-pc-windows-gnu/release"
		"X11":
			return "/mnt/p/Brick Hill/game/support_code/target/x86_64-unknown-linux-musl/release"
		_:
			printerr("No dev bin dir specified for this OS")
			return ""

static func get_executable_path()->String:
	return OS.get_executable_path().replace("\\", "/")

static func get_executable_directory()->String:
	return get_executable_path().get_base_dir()

static func get_valid_bin_dir()->String:
	var bin_dir: = get_bin_dir()

	var dir = Directory.new()
	if dir.dir_exists(bin_dir):
		return bin_dir
	else :
		var dev_bin_dir: = get_dev_bin_dir()
		if dir.dir_exists(dev_bin_dir):
			return dev_bin_dir
		else :
			printerr("Dev binary directory %s does not exist")
			return ""

static func get_updates_dir()->String:
	var user_data_dir = OS.get_user_data_dir()
	return user_data_dir + "/updates"

static func get_update_zip(tag:String)->String:
	var updates_dir = get_updates_dir()
	return updates_dir + "/brick-hill-%s.zip" % [tag]

static func get_installed_updater()->String:
	var user_data_dir = OS.get_user_data_dir()
	return user_data_dir.plus_file(get_platform_updater_executable_filename())

static func get_new_updater()->String:
	var bin_dir = get_valid_bin_dir()
	return bin_dir.plus_file(get_platform_updater_executable_filename())

static func get_platform_updater_executable_filename()->String:
	return UPDATER_EXECUTABLE + get_platform_executable_suffix()

static func get_platform_executable_suffix()->String:
	if OS.get_name() == "Windows":
		return ".exe"
	return ""
