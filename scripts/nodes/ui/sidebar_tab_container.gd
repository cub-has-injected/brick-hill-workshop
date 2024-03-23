class_name SidebarTabContainer
extends TabContainer
tool 

signal visible_changed(new_visible)

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	connect("tab_changed", self, "tab_changed")
	connect("visibility_changed", self, "visibility_changed")

func set_tab(index:int)->void :
	var scope = Profiler.scope(self, "set_tab", [index])

	if current_tab == index:
		set_current_tab(0)
	else :
		set_current_tab(index)

func tab_changed(index:int)->void :
	var scope = Profiler.scope(self, "tab_changed", [index])

	set_visible(index > 0)

func visibility_changed()->void :
	var scope = Profiler.scope(self, "visibility_changed", [])

	emit_signal("visible_changed", visible)

func set_disabled(new_disabled:bool)->void :
	var scope = Profiler.scope(self, "set_disabled", [new_disabled])

	var nodes: = [
		$FileTab, 
		$WorkspaceTab, 
		$EnvironmentTab
	]

	for node in nodes:
		node.set_disabled(new_disabled)
