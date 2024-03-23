class_name BrickHillColorPicker
extends Control
tool 

signal color_changed(color)
signal color_committed(color)

signal recursive_focus_exited()

export (Color) var color = Color.white setget set_color
export (float, 0, 1, 0.01) var hue_ring_size = 0.25 setget set_hue_ring_size
export (float, 0, 1, 0.01) var color_lens_size = 0.05 setget set_color_lens_size

var picking: = false setget set_picking

func set_picking(new_picking:bool)->void :
	var scope = Profiler.scope(self, "set_picking", [new_picking])

	if picking != new_picking:
		picking = new_picking
		if is_inside_tree():
			update_picking()


func set_color(new_color:Color)->void :
	var scope = Profiler.scope(self, "set_color", [new_color])

	if color != new_color:
		color = new_color
		if is_inside_tree():
			update_color()

func set_hue_ring_size(new_hue_ring_size:float)->void :
	var scope = Profiler.scope(self, "set_hue_ring_size", [new_hue_ring_size])

	if hue_ring_size != new_hue_ring_size:
		hue_ring_size = new_hue_ring_size
		if is_inside_tree():
			update_hue_ring_size()

func set_color_lens_size(new_color_lens_size:float)->void :
	var scope = Profiler.scope(self, "set_color_lens_size", [new_color_lens_size])

	if color_lens_size != new_color_lens_size:
		color_lens_size = new_color_lens_size
		if is_inside_tree():
			update_color_lens_size()


func get_hue_ring()->Control:
	var scope = Profiler.scope(self, "get_hue_ring", [])

	return $HBoxContainer / VBoxContainer / MarginContainer / HueRing as Control

func get_color_preview()->ColorRect:
	var scope = Profiler.scope(self, "get_color_preview", [])

	return $HBoxContainer / VBoxContainer / MarginContainer2 / HBoxContainer / Border / ColorPreview as ColorRect

func get_hex_color()->LineEdit:
	var scope = Profiler.scope(self, "get_hex_color", [])

	return $HBoxContainer / VBoxContainer / MarginContainer2 / HBoxContainer / LineEdit as LineEdit

func get_eyedropper_button()->Button:
	var scope = Profiler.scope(self, "get_eyedropper_button", [])

	return $HBoxContainer / VBoxContainer / MarginContainer2 / HBoxContainer / Eyedropper as Button


func update_color()->void :
	var scope = Profiler.scope(self, "update_color", [])

	get_hue_ring().set_color(color)

	var color_preview = get_color_preview()
	if color_preview:
		color_preview.color = color

	var hex_color = get_hex_color()
	if hex_color:
		hex_color.text = "#" + color.to_html(false).to_upper()

func update_hue_ring_size()->void :
	var scope = Profiler.scope(self, "update_hue_ring_size", [])

	get_hue_ring().set_hue_ring_size(hue_ring_size)

func update_color_lens_size()->void :
	var scope = Profiler.scope(self, "update_color_lens_size", [])

	get_hue_ring().set_color_lens_size(color_lens_size)

func update_picking()->void :
	var scope = Profiler.scope(self, "update_picking", [])

	var button = get_eyedropper_button()
	button.set_block_signals(true)
	button.pressed = picking
	button.set_block_signals(false)

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	connect("focus_exited", self, "check_recursive_focus_exited")


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	update_color()
	update_hue_ring_size()
	update_color_lens_size()

func _input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_input", [event])

	if picking:
		if event is InputEventMouseMotion:
			if get_global_rect().has_point(event.global_position):
				return 

			WorkshopDirectory.main_viewport().unhandled_input(event.xformed_by(WorkshopDirectory.viewport_control().get_transform().inverse()))

			var new_color = WorkshopDirectory.eyedropper_manager().hovered_color
			set_color(new_color)
			emit_signal("color_changed", new_color)
			emit_signal("color_committed", new_color)
		elif event is InputEventMouseButton:
			if event.pressed:
				set_picking(false)
				get_viewport().set_input_as_handled()


func color_changed(new_color:Color)->void :
	var scope = Profiler.scope(self, "color_changed", [new_color])

	set_color(new_color)
	emit_signal("color_changed", new_color)

func color_committed(new_color:Color)->void :
	var scope = Profiler.scope(self, "color_committed", [new_color])

	set_color(new_color)
	emit_signal("color_committed", new_color)

func start_picking()->void :
	var scope = Profiler.scope(self, "start_picking", [])

	picking = true

func on_hex_color_changed(new_text:String)->void :
	var scope = Profiler.scope(self, "on_hex_color_changed", [new_text])

	var new_color = Color(new_text)
	set_color(new_color)
	emit_signal("color_changed", new_color)
	emit_signal("color_committed", new_color)
