class_name CollisionSettings
extends Node

signal resolve_collision_changed(new_resolve_collision)

export (bool) var resolve_collision: = true setget set_resolve_collision

func set_resolve_collision(new_resolve_collision:bool)->void :
	var scope = Profiler.scope(self, "set_resolve_collision", [new_resolve_collision])

	if resolve_collision != new_resolve_collision:
		resolve_collision = new_resolve_collision
		if is_inside_tree():
			update_resolve_collision()

func toggle_resolve_collision()->void :
	var scope = Profiler.scope(self, "toggle_resolve_collision", [])

	set_resolve_collision( not resolve_collision)

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_resolve_collision()

func update_resolve_collision()->void :
	var scope = Profiler.scope(self, "update_resolve_collision", [])

	emit_signal("resolve_collision_changed", resolve_collision)
