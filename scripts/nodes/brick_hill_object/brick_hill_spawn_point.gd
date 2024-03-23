class_name BrickHillSpawnPoint
extends BrickHillObject

func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "SpawnPoint"

func get_set_root_ancestor()->SetRoot:
	var scope = Profiler.scope(self, "get_set_root_ancestor")

	var candidate = self
	while true:
		candidate = candidate.get_parent()
		if not candidate:
			break
		if candidate is SetRoot:
			return candidate
	return null

func get_tree_icon(highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon", [highlight])

	return BrickHillResources.ICONS.tree_highlight_special if highlight else BrickHillResources.ICONS.tree_special

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	var owner = get_set_root_ancestor()
	if owner:
		owner.register_spawn_point(self)

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree")

	var owner = get_set_root_ancestor()
	if owner:
		owner.unregister_spawn_point(self)
