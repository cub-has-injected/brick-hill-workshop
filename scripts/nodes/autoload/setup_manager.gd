extends Node
tool 

const SETUP_INFO_FILE: = "user://setup_info"
const SETUP_EXECUTABLE: = "brick_hill_setup"

var brick_hill_native

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	_disable_abort_on_missing_resource_dependencies()
	_setup_brick_hill_native()
	_try_setup_brick_hill_setup()

func _disable_abort_on_missing_resource_dependencies()->void :
	var scope = Profiler.scope(self, "_disable_abort_on_missing_resource_dependencies", [])

	ResourceLoader.set_abort_on_missing_resources(false)

func _setup_brick_hill_native()->void :
	var scope = Profiler.scope(self, "_setup_brick_hill_native", [])



func _try_setup_brick_hill_setup()->void :
	var scope = Profiler.scope(self, "_try_setup_brick_hill_setup", [])

	var exe_path = BrickHillSupportCode.get_executable_path()
	var bin_dir = BrickHillSupportCode.get_valid_bin_dir()
	if bin_dir.empty():
		printerr("Setup manager failed to get valid bin dir")
		return 

	var setup_params: = [exe_path, bin_dir]
	var setup_exe = bin_dir.plus_file(SETUP_EXECUTABLE)

	
	var setup_info_file = ConfigFile.new()

	
	if Directory.new().file_exists(SETUP_INFO_FILE):
		
		setup_info_file.load(SETUP_INFO_FILE)
		var cached_bin_dir = setup_info_file.get_value("paths", "bin_dir")
		if bin_dir == cached_bin_dir:
			
			print("Setup has already run for this location, skipping...")
			return 

	
	print("Running %s with parameters %s" % [setup_exe, setup_params])
	var result: = OS.execute(setup_exe, setup_params)
	match result:
		- 1:
			printerr("Failed to execute setup process")
		0:
			print("Setup successful")
		1:
			printerr("Unspecified setup error")
		_:
			printerr("Setup error %s" % [result])

	
	setup_info_file.set_value("paths", "bin_dir", bin_dir)
	setup_info_file.save(SETUP_INFO_FILE)
