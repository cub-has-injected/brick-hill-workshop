extends Node

onready var SKYBOXES: = {
	"blue_sky":BrickHillAsset.new(416649), 
	"cumulus":BrickHillAsset.new(416652), 
	"deep_space":BrickHillAsset.new(416653), 
	"midnight":BrickHillAsset.new(416654), 
	"midnight_mountain":BrickHillAsset.new(416655), 
	"sunset":BrickHillAsset.new(416656), 
	"nebula":BrickHillAsset.new(416662), 
	"cloudy":BrickHillAsset.new(416663), 
}

func get_load_progress()->float:
	var scope = Profiler.scope(self, "get_load_progress", [])

	var progress = 0.0
	for asset in SKYBOXES.values():
		progress += asset.get_load_progress()
	progress /= SKYBOXES.size()
	return progress
