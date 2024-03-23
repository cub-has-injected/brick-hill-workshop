class_name CompositeRigidBody
extends CompositeRigidBodyBase
tool 

export (bool) var enabled: = true setget set_enabled

var _cached_children: = []


func set_enabled(new_enabled:bool)->void :
	var scope = Profiler.scope(self, "set_enabled", [new_enabled])

	if enabled != new_enabled:
		enabled = new_enabled
		enabled_changed()


func enabled_changed()->void :
	var scope = Profiler.scope(self, "enabled_changed", [])

	update()

func children_changed()->void :
	var scope = Profiler.scope(self, "children_changed", [])

	update()


func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if not enabled and mode != MODE_STATIC:
		mode = MODE_STATIC
		property_list_changed_notify()

	var changed: = false
	var child_count = get_child_count()

	if _cached_children.size() != child_count:
		changed = true
	else :
		for i in range(0, child_count):
			if get_child(i) != _cached_children[i]:
				changed = true
				break

	if changed:
		_cached_children.clear()
		for child in get_children():
			_cached_children.append(child)
		children_changed()


func update()->void :
	var scope = Profiler.scope(self, "update", [])

	clear()
	var children = find_rigid_body_children(self)
	for child_rigid_body in children:
		child_rigid_body.mode = MODE_RIGID

	if enabled:
		update_transform()
		compose_shape_owners(children)

		for child_rigid_body in children:
			child_rigid_body.mode = MODE_STATIC

func find_rigid_body_children(node:Node)->Array:
	var scope = Profiler.scope(self, "find_rigid_body_children", [node:Node])

	var rigid_bodies: = []

	for child in node.get_children():
		if child is RigidBody:
			rigid_bodies.append(child)
		rigid_bodies += find_rigid_body_children(child)
	return rigid_bodies

func update_transform()->void :
	var scope = Profiler.scope(self, "update_transform", [])

	var child_transforms: = {}
	for child_rigid_body in find_rigid_body_children(self):
		child_transforms[child_rigid_body] = child_rigid_body.global_transform

	global_transform.origin = Vector3.ZERO
	for child in child_transforms:
		var trx = child_transforms[child]
		global_transform.origin += trx.origin

	global_transform.origin /= child_transforms.size()

	for child in child_transforms:
		var trx = child_transforms[child]
		child.global_transform.origin = trx.origin
