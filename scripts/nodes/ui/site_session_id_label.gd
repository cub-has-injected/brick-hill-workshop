class_name SiteSessionIDLabel
extends Label
tool 

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	SiteSession.connect("id_changed", self, "update_id")
	update_id()

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	SiteSession.disconnect("id_changed", self, "update_id")

func update_id()->void :
	var scope = Profiler.scope(self, "update_id", [])

	text = "%s" % [SiteSession.id]
