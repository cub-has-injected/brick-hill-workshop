extends Node

signal versions_changed()

const UPDATES_PATH = "user://updates/"
const UPDATE_PATTERN = "brick-hill-(.*).zip"
const UPDATE_INFO_FILE = "user://update_info"

var _update_regex:RegEx = null

var _local_updates: = {
	"debug":[], 
	"release":[]
}

var _site_updates: = {
	"debug":[], 
	"release":[], 
}

func get_platform_string()->String:
	var scope = Profiler.scope(self, "get_platform_string", [])

	match OS.get_name():
		"Windows":
			return "windows"
		"OSX":
			return "mac"
		"X11":
			return "linux"
	
	assert (false)
	return ""

func run_local_update(channel:String, tag:String, new_version:String)->bool:
	var scope = Profiler.scope(self, "run_local_update", [channel, tag, new_version])

	print("Updating to %s" % [new_version])

	var target_update = BrickHillSupportCode.get_update_zip(new_version)

	if Directory.new().file_exists(target_update):
		print("Target update exists.")
	else :
		printerr("Target update does not exist.")
		return false

	var updater_exe_source = BrickHillSupportCode.get_new_updater()
	var updater_exe_target = BrickHillSupportCode.get_installed_updater()

	
	stage_updater(updater_exe_source, updater_exe_target)

	
	var updater_params: = ["--local", channel, tag, target_update]
	exec_updater(updater_exe_target, updater_params)

	return true

func stage_updater(updater_exe_source:String, updater_exe_target:String)->void :
	var scope = Profiler.scope(self, "stage_updater", [updater_exe_source, updater_exe_target])

	
	var copy_result = Directory.new().copy(updater_exe_source, updater_exe_target)
	assert (copy_result == OK, "Failed to copy updater executable")

	
	if get_platform_string() == "mac" or get_platform_string() == "linux":
		var result = OS.execute("chmod", PoolStringArray(["+x", updater_exe_target]))
		assert (result == OK, "chmod failed with code %s" % [result])

	print("Updater exe. Source: %s, Target: %s" % [updater_exe_source, updater_exe_target])

func exec_updater(updater_exe_target:String, updater_params:Array)->void :
	var scope = Profiler.scope(self, "exec_updater", [updater_exe_target, updater_params])

	print("Running %s with parameters %s" % [updater_exe_target, updater_params])
	OS.execute(updater_exe_target, updater_params, false)
	get_tree().quit()

func _init()->void :
	_update_regex = RegEx.new()
	var result = _update_regex.compile(UPDATE_PATTERN)
	assert (result == OK)
	fetch_local_updates("debug")
	fetch_local_updates("release")

	if not Directory.new().file_exists(UPDATE_INFO_FILE):
		var update_info_file = ConfigFile.new()
		update_info_file.save(UPDATE_INFO_FILE)

func get_version_list(channel:String)->Array:
	var scope = Profiler.scope(self, "get_version_list", [channel])

	var version_dict: = {}
	for version in _local_updates[channel] + _site_updates[channel]:
		if version.tag in version_dict:
			version_dict[version.tag].local = version_dict[version.tag].local or version.local
			version_dict[version.tag].site = version_dict[version.tag].site or version.site
		else :
			version_dict[version.tag] = version

	var versions = version_dict.values()
	versions.sort_custom(self, "sort_versions")
	return versions

func sort_versions(lhs, rhs)->bool:
	var scope = Profiler.scope(self, "sort_versions", [lhs, rhs])

	var lhs_dt = UpdateInfo.parse_iso_date(lhs.created_at)
	var rhs_dt = UpdateInfo.parse_iso_date(rhs.created_at)
	var lhs_unix = OS.get_unix_time_from_datetime(lhs_dt)
	var rhs_unix = OS.get_unix_time_from_datetime(rhs_dt)
	return lhs_unix > rhs_unix

func fetch_local_updates(channel:String)->void :
	var scope = Profiler.scope(self, "fetch_local_updates", [channel])

	var result

	var dir: = Directory.new()
	result = dir.make_dir_recursive(UPDATES_PATH)
	assert (result == OK)

	result = dir.open(UPDATES_PATH)
	assert (result == OK)

	var file_tags: = []
	result = dir.list_dir_begin(true, true)
	assert (result == OK)
	while true:
		var file = dir.get_next()
		if file.empty():
			break

		var regex_match = _update_regex.search(file)
		if regex_match == null:
			continue

		file_tags.append(regex_match.strings[1])

	var update_info_file = ConfigFile.new()
	update_info_file.load(UPDATE_INFO_FILE)

	_local_updates[channel].clear()

	for section in update_info_file.get_sections():
		var parts = section.split(".")
		var section_channel = parts[0]
		if section_channel != channel:
			continue

		parts.remove(0)

		var section_tag = parts.join(".")
		if section_tag in file_tags:
			var update_info = UpdateInfo.new()
			update_info.tag = section_tag
			update_info.created_at = update_info_file.get_value(section, "created_at")
			update_info.channel = channel
			update_info.local = true
			_local_updates[channel].append(update_info)
		else :
			printerr("Missing update file for version %s, removing from info cache." % [section_tag])
			update_info_file.erase_section(section)

	emit_signal("versions_changed")

func get_version_zip_name(version:String)->String:
	var scope = Profiler.scope(self, "get_version_zip_name", [version])

	return "brick-hill-%s.zip" % version


func fetch_site_updates(channel:String)->void :
	var scope = Profiler.scope(self, "fetch_site_updates", [channel])

	print_debug("Fetching updates...")




func updates_success(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "updates_success", [response_body, metadata])

	var response_string = response_body.get_string_from_ascii()
	var parse_result = JSON.parse(response_string)
	var info_result = parse_result.result

#	var access_token = BrickHillAuth.get_access_token()
#

	print("Updates fetched successfully.")
	_site_updates[metadata.channel].clear()
	for update in info_result.data:
		var update_info = UpdateInfo.new()
		update_info.tag = update.tag
		update_info.created_at = update.created_at
		update_info.channel = metadata.channel
		update_info.site = true
		_site_updates[metadata.channel].append(update_info)
	emit_signal("versions_changed")

func updates_failed(error:String)->void :
	var scope = Profiler.scope(self, "updates_failed", [error])

	printerr(error)

func delete_update(update:UpdateInfo)->void :
	var scope = Profiler.scope(self, "delete_update", [update])

	var result = Directory.new().remove("user://updates/brick-hill-%s.zip" % [update.tag])
	assert (result == OK)
	fetch_local_updates(update.channel)

func run_remote_update(update:UpdateInfo)->void :
	var scope = Profiler.scope(self, "run_remote_update", [update])

#	var access_token = BrickHillAuth.get_access_token()



func download_update_success(response_body:PoolByteArray, metadata:Dictionary)->void :
	var scope = Profiler.scope(self, "download_update_success", [response_body, metadata])

	var aws_url = response_body.get_string_from_ascii()
	exec_remote_update(metadata.update.channel, metadata.update.tag, metadata.update.created_at, aws_url)

func exec_remote_update(channel:String, tag:String, created_at:String, url:String)->void :
	var scope = Profiler.scope(self, "exec_remote_update", [channel, tag, created_at, url])

	print("Executing remote update %s" % [tag])

	var target_update = BrickHillSupportCode.get_update_zip(tag)

	var updater_exe_source = BrickHillSupportCode.get_new_updater()
	var updater_exe_target = BrickHillSupportCode.get_installed_updater()

	
	stage_updater(updater_exe_source, updater_exe_target)

	
	var updater_params: = ["--remote", channel, tag, created_at, url]
	exec_updater(updater_exe_target, updater_params)

func download_update_failed(error:String)->void :
	var scope = Profiler.scope(self, "download_update_failed", [error])

	printerr("Download update failed: %s" % [error])
