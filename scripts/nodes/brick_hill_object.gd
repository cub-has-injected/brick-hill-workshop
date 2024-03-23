class_name BrickHillObject
extends Spatial
tool 

const PRINT: = false


export (Vector3) var size: = Vector3.ONE setget set_size, get_size
export (Array, bool) var flip:Array setget set_flip

export (bool) var anchored: = false setget set_anchored
export (bool) var locked: = false

var frozen: = true


var object_mode = BrickHillUtil.ObjectMode.DYNAMIC setget set_object_mode


func set_size(new_size:Vector3)->void :
	var scope = Profiler.scope(self, "set_size", [new_size])

	for i in range(0, 3):
		if new_size[i] <= 0.0:
			new_size[i] = 0.01

	if size != new_size:
		size = new_size
		if is_inside_tree():
			size_changed()

func set_flip(new_flip:Array)->void :
	var scope = Profiler.scope(self, "set_flip", [new_flip])

	for i in range(0, 3):
		if not new_flip[i] is bool:
			new_flip[i] = false

	flip = new_flip
	if is_inside_tree():
		flip_changed()

func toggle_flip(x:bool, y:bool, z:bool)->void :
	var scope = Profiler.scope(self, "toggle_flip", [x, y, z])

	var new_flip = flip.duplicate()

	if x:
		new_flip[0] = not flip[0]
	if y:
		new_flip[1] = not flip[1]
	if z:
		new_flip[2] = not flip[2]

	set_flip(new_flip)

func set_anchored(new_anchored:bool)->void :
	var scope = Profiler.scope(self, "set_anchored", [new_anchored])

	if anchored != new_anchored:
		anchored = new_anchored
		if is_inside_tree():
			anchored_changed()

func set_object_mode(new_object_mode:int)->void :
	var scope = Profiler.scope(self, "set_object_mode", [new_object_mode])

	if object_mode != new_object_mode:
		object_mode = new_object_mode
		if is_inside_tree():
			object_mode_changed()

func set_name(new_name:String)->void :
	var scope = Profiler.scope(self, "set_name", [new_name])

	if new_name.empty():
		new_name = get_default_name()
	.set_name(new_name)


func get_default_name()->String:
	var scope = Profiler.scope(self, "get_default_name")

	return "Object"

func get_size()->Vector3:
	var scope = Profiler.scope(self, "get_size")

	return size

func get_hovered_face_idx(normal:Vector3)->int:
	var scope = Profiler.scope(self, "get_hovered_face_idx", [normal])

	if PRINT:
		print_debug("%s get hovered face idx for %s" % [get_name(), normal])

	return - 1

func get_bounds()->AABB:
	var scope = Profiler.scope(self, "get_bounds")

	var aabb = AABB()

	for child in get_children():
		if child as BrickHillObject:
			var temp_trx = child.transform
			temp_trx.basis = temp_trx.basis.orthonormalized()
			var child_aabb = temp_trx.xform(child.get_bounds())
			aabb = aabb.merge(child_aabb)

	return aabb

func get_tree_icon(_highlight:bool = false)->Texture:
	var scope = Profiler.scope(self, "get_tree_icon", [_highlight])

	return null


func size_changed()->void :
	var scope = Profiler.scope(self, "size_changed")

	pass

func flip_changed()->void :
	var scope = Profiler.scope(self, "flip_changed")

	pass

func anchored_changed()->void :
	var scope = Profiler.scope(self, "anchored_changed")

	set_object_mode(BrickHillUtil.ObjectMode.STATIC if anchored else BrickHillUtil.ObjectMode.DYNAMIC)

func object_mode_changed()->void :
	var scope = Profiler.scope(self, "object_mode_changed")

	if PRINT:
		print_debug("%s object mode changed" % [get_name()])


func _init()->void :
	var scope = Profiler.scope(self, "_init")

	name = get_default_name()
	flip = [false, false, false]

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree")

	if PRINT:
		print_debug("%s enter tree" % [get_name()])

	set_notify_transform(true)

	call_deferred("initial_update")

func initial_update()->void :
	var scope = Profiler.scope(self, "initial_update")

	size_changed()
	flip_changed()

	object_mode = BrickHillUtil.ObjectMode.STATIC if anchored else BrickHillUtil.ObjectMode.DYNAMIC
	object_mode_changed()

func freeze()->void :
	var scope = Profiler.scope(self, "freeze")

	if PRINT:
		print_debug("%s freeze" % [get_name()])

	frozen = true

func unfreeze()->void :
	var scope = Profiler.scope(self, "unfreeze")

	if PRINT:
		print_debug("%s unfreeze" % [get_name()])

	frozen = false

func get_custom_categories()->Dictionary:
	return {
		"Object":{
			"Transform":[
				"translation", 
				"rotation_degrees", 
				"size", 
				"flip", 
			], 
			"Behavior":[
				"anchored", 
				"locked", 
			]
		}, 
	}

func get_custom_property_names()->Dictionary:
	return {
		"translation":"Position", 
		"rotation_degrees":"Rotation", 
	}

func get_property_enabled(property:String)->bool:
	match property:
		"translation":
			return not locked
		"rotation_degrees":
			return not locked
		"size":
			return not locked
		"flip":
			return not locked

	return true
