class_name EnvironmentPropertyEditor
extends PropertyEditor
tool 

func get_target_objects()->Array:
	var scope = Profiler.scope(self, "get_target_objects", [])

	var set_root = WorkshopDirectory.set_root()
	if not set_root:
		return []

	var environment = set_root.get_node_or_null("BrickHillEnvironment")
	if not environment:
		return []

	return [environment]
