class_name SnapSettings
extends Node

signal snap_move_step_changed(new_snap_move_step)
signal snap_rotate_step_changed(new_snap_rotate_step)

export (bool) var snap_move: = false setget set_snap_move
export (float) var snap_move_step: = 1.0 setget set_snap_move_step

export (bool) var snap_rotate: = false setget set_snap_rotate
export (float) var snap_rotate_step: = 10.0 setget set_snap_rotate_step


func set_snap_move(new_snap_move:bool)->void :
	var scope = Profiler.scope(self, "set_snap_move", [new_snap_move])

	if snap_move != new_snap_move:
		snap_move = new_snap_move

func set_snap_rotate(new_snap_rotate:bool)->void :
	var scope = Profiler.scope(self, "set_snap_rotate", [new_snap_rotate])

	if snap_rotate != new_snap_rotate:
		snap_rotate = new_snap_rotate

func set_snap_move_step(value:float)->void :
	var scope = Profiler.scope(self, "set_snap_move_step", [value])

	snap_move_step = value
	if is_inside_tree():
		update_snap_move_step()

func set_snap_rotate_step(value:float)->void :
	var scope = Profiler.scope(self, "set_snap_rotate_step", [value])

	snap_rotate_step = value
	if is_inside_tree():
		update_snap_rotate_step()


func update_snap_move_step()->void :
	var scope = Profiler.scope(self, "update_snap_move_step", [])

	emit_signal("snap_move_step_changed", snap_move_step)

func update_snap_rotate_step()->void :
	var scope = Profiler.scope(self, "update_snap_rotate_step", [])

	emit_signal("snap_rotate_step_changed", snap_rotate_step)


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_snap_move_step()
	update_snap_rotate_step()
