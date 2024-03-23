class_name CameraWidget
extends Control
tool 

export (float) var fade_speed = 5.0

var _target_opacity: = 0.0

func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	modulate.a = 0.0

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	modulate.a = lerp(modulate.a, _target_opacity, delta * fade_speed)

func set_zoom(zoom_scalar:float)->void :
	var scope = Profiler.scope(self, "set_zoom", [zoom_scalar])

	_target_opacity = 1.0
	$MarginContainer / HBoxContainer / Label.text = "Zoom"
	$MarginContainer / HBoxContainer / Slider.value = 1.0 - zoom_scalar
	$FadeOutTimer.start()

func set_move_speed(move_speed_scalar:float)->void :
	var scope = Profiler.scope(self, "set_move_speed", [move_speed_scalar])

	_target_opacity = 1.0
	$MarginContainer / HBoxContainer / Label.text = "Speed"
	$MarginContainer / HBoxContainer / Slider.value = move_speed_scalar
	$FadeOutTimer.start()


func fade_out()->void :
	var scope = Profiler.scope(self, "fade_out", [])

	_target_opacity = 0.0
