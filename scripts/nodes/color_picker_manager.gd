class_name ColorPickerManager
extends Node
tool 

var color_picker_popup:Popup
var color_picker:BrickHillColorPicker
var summoning_control:Control
var picker_origin:int
var control_origin:int

var event_target:Node
var event_name:String

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	color_picker_popup = WorkshopDirectory.color_picker_popup()
	color_picker = WorkshopDirectory.color_picker()

	color_picker_popup.connect("hide", self, "color_picker_hidden")
	color_picker.connect("color_changed", self, "color_changed")

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if color_picker_popup and summoning_control:
		var target_rect = color_picker_popup.get_global_rect()
		target_rect.position = summoning_control.rect_global_position

		match control_origin:
			CORNER_TOP_LEFT:
				pass
			CORNER_TOP_RIGHT:
				target_rect.position.x += summoning_control.rect_size.x
			CORNER_BOTTOM_LEFT:
				target_rect.position.y += summoning_control.rect_size.y
			CORNER_BOTTOM_RIGHT:
				target_rect.position += summoning_control.rect_size

		match picker_origin:
			CORNER_TOP_LEFT:
				pass
			CORNER_TOP_RIGHT:
				target_rect.position.x -= color_picker_popup.rect_size.x
			CORNER_BOTTOM_LEFT:
				target_rect.position.y -= color_picker_popup.rect_size.y
			CORNER_BOTTOM_RIGHT:
				target_rect.position -= color_picker_popup.rect_size

		var clip_control = color_picker_popup.get_parent()
		while true:
			var candidate = clip_control.get_parent()
			if candidate is Control and not clip_control.rect_clip_content:
				clip_control = candidate
			else :
				break

		var clip_rect = clip_control.get_global_rect()

		if not clip_rect.encloses(target_rect):
			var pos_delta = clip_rect.position - target_rect.position
			var end_delta = target_rect.end - clip_rect.end

			"\n			if pos_delta.x > 0:\n				target_rect.position.x += pos_delta.x\n			"
			if pos_delta.y > 0:
				target_rect.position.y += pos_delta.y
			"\n			if end_delta.x > 0:\n				target_rect.position.x -= end_delta.x\n			"
			if end_delta.y > 0:
				target_rect.position.y -= end_delta.y

		color_picker_popup.rect_global_position = target_rect.position

func color_picker_hidden()->void :
	var scope = Profiler.scope(self, "color_picker_hidden", [])

	if summoning_control:
		if "pressed" in summoning_control:
			summoning_control.pressed = false
		summoning_control = null

	event_target = null
	event_name = ""

func color_changed(new_color:Color)->void :
	var scope = Profiler.scope(self, "color_changed", [new_color])

	if event_target and event_target.has_method(event_name):
		event_target.call(event_name, new_color)

func set_picker_color(color:Color)->void :
	var scope = Profiler.scope(self, "set_picker_color", [color])

	color_picker.set_color(color)

func set_picker_connection(target:Object, method:String)->void :
	var scope = Profiler.scope(self, "set_picker_connection", [target, method])

	event_target = target
	event_name = method

func show_picker_at_control(control:Control, parent:Control, in_picker_origin:int, in_control_origin:int)->void :
	var scope = Profiler.scope(self, "show_picker_at_control", [control, parent, in_picker_origin, in_control_origin])

	summoning_control = control
	picker_origin = in_picker_origin
	control_origin = in_control_origin
	color_picker_popup.get_parent().remove_child(color_picker_popup)
	parent.add_child(color_picker_popup)
	color_picker_popup.show_modal()
