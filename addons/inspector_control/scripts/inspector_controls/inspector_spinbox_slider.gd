class_name InspectorSpinboxSlider
extends HBoxContainer

signal property_change_begin(name)
signal property_changed(name, value)
signal property_change_end(name)

var _object:Object = null
var _property:Dictionary

var _spin_box:InspectorSpinBox
var _slider:InspectorSlider

func get_orientation()->int:
	return HORIZONTAL

func _init()->void :
	size_flags_horizontal = SIZE_EXPAND_FILL

	set("custom_constants/separation", 8)

	_spin_box = InspectorSpinBox.new()
	_spin_box.size_flags_horizontal = SIZE_SHRINK_END
	_spin_box.set_meta("inspector_spin_box_slider_child", true)
	_spin_box.connect("property_change_begin", self, "on_property_change_begin")
	_spin_box.connect("property_changed", self, "on_property_changed")
	_spin_box.connect("property_change_end", self, "on_property_change_end")

	_slider = InspectorSlider.new()
	_slider.set_meta("inspector_spin_box_slider_child", true)
	_slider.connect("property_change_begin", self, "on_property_change_begin")
	_slider.connect("property_changed", self, "on_property_changed")
	_slider.connect("property_change_end", self, "on_property_change_end")

func _enter_tree()->void :
	for child in get_children():
		if child.has_meta("inspector_spin_box_slider_child", true):
			remove_child(child)
			child.queue_free()

	add_child(_slider)
	add_child(_spin_box)

func supported_property(property:Dictionary)->bool:
	return _slider.supported_property(property)

func set_data(object:Object, property:Dictionary)->void :
	_slider.set_data(object, property)
	_spin_box.set_data(object, property)

func on_property_change_begin(name:String)->void :
	emit_signal("property_change_begin", name)

func on_property_changed(name, value)->void :
	emit_signal("property_changed", name, value)

func on_property_change_end(name:String)->void :
	emit_signal("property_change_end", name)

func set_enabled(new_enabled:bool)->void :
	_slider.set_enabled(new_enabled)
	_spin_box.set_enabled(new_enabled)
