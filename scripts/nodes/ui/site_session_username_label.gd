class_name SiteSessionUsernameLabel
extends Label
tool 

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	SiteSession.connect("username_changed", self, "update_username")
	update_username()

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	SiteSession.disconnect("username_changed", self, "update_username")

func update_username()->void :
	var scope = Profiler.scope(self, "update_username", [])

	text = SiteSession.username
