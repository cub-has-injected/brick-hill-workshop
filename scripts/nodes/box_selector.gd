class_name BoxSelector
extends Area
tool 

signal active_changed(new_active)

export (bool) var active: = false setget set_active

func set_active(new_active:bool)->void :
	var scope = Profiler.scope(self, "set_active", [new_active])

	if active != new_active:
		active = new_active
		active_changed()

func toggle_active()->void :
	var scope = Profiler.scope(self, "toggle_active", [])

	set_active( not active)


func set_size(new_size:Vector3)->void :
	var scope = Profiler.scope(self, "set_size", [new_size])

	$CollisionShape.shape.extents = new_size / 2.0

func get_size()->Vector3:
	var scope = Profiler.scope(self, "get_size", [])

	return $CollisionShape.shape.extents * 2.0


func get_shapes()->InterfaceShapes.Shapes:
	var scope = Profiler.scope(self, "get_shapes", [])

	var shapes = InterfaceShapes.Shapes.new()
	shapes.add_shape(global_transform, $CollisionShape.shape)
	return shapes

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	active_changed()

func active_changed()->void :
	var scope = Profiler.scope(self, "active_changed", [])

	visible = active
	emit_signal("active_changed", active)

func _physics_process(delta:float)->void :
	var scope = Profiler.scope(self, "_physics_process", [delta])

	if not active:
		return 

	var selected_nodes = WorkshopDirectory.selected_nodes()

	var selection = []
	for node in get_overlapping_bodies():
		if InterfaceSelectable.is_implementor(node):
			var selected = InterfaceSelectable.get_selection(node)
			var group_ancestor = WorkshopDirectory.group_manager().find_group_ancestor(selected, true, true)
			if group_ancestor:
				selected = group_ancestor

			if not selected in selection:
				selection.append(selected)

	for node in selection:
		if not node in selected_nodes.selected_nodes:
			selected_nodes.add_selected_node(node)

	for node in selected_nodes.selected_nodes:
		if not node in selection:
			selected_nodes.remove_selected_node(node)
