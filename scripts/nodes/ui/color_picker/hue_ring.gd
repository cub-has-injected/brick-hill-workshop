class_name HueRing
extends Control
tool 

signal color_changed(color)
signal color_committed(color)

enum State{
	IDLE
	HUE, 
	SATURATION_VALUE, 
	SCREEN
}

const LERP_SPEED = 20.0

export (Color) var color = Color.white setget set_color
export (float, 0, 1, 0.01) var hue_ring_size = 0.25 setget set_hue_ring_size
export (float, 0, 1, 0.01) var color_lens_size = 0.05 setget set_color_lens_size

var hue: = 0.0 setget set_hue
var saturation: = 0.0 setget set_saturation
var value: = 1.0 setget set_value
var state:int = State.IDLE setget set_state

var sv_position: = Vector2.ZERO

var _hue: = 0.0
var _saturation: = 0.0
var _value: = 1.0


func set_color(new_color:Color)->void :
	var scope = Profiler.scope(self, "set_color", [new_color])

	if color != new_color:
		saturation = new_color.s
		if saturation > 0:
			hue = new_color.h
		value = new_color.v

		if is_inside_tree():
			update_color()
			update()

func set_hue_ring_size(new_hue_ring_size:float)->void :
	var scope = Profiler.scope(self, "set_hue_ring_size", [new_hue_ring_size])

	if hue_ring_size != new_hue_ring_size:
		hue_ring_size = new_hue_ring_size
		if is_inside_tree():
			update_size()
			update()

func set_color_lens_size(new_color_lens_size:float)->void :
	var scope = Profiler.scope(self, "set_color_lens_size", [new_color_lens_size])

	if color_lens_size != new_color_lens_size:
		color_lens_size = new_color_lens_size
		if is_inside_tree():
			update()

func set_hue(new_hue:float)->void :
	var scope = Profiler.scope(self, "set_hue", [new_hue])

	if hue != new_hue:
		hue = new_hue
		if is_inside_tree():
			update_color()

func set_saturation(new_saturation:float)->void :
	var scope = Profiler.scope(self, "set_saturation", [new_saturation])

	if saturation != new_saturation:
		saturation = new_saturation
		if is_inside_tree():
			update_color()

func set_value(new_value:float)->void :
	var scope = Profiler.scope(self, "set_value", [new_value])

	if value != new_value:
		value = new_value
		if is_inside_tree():
			update_color()

func set_state(new_state:int)->void :
	var scope = Profiler.scope(self, "set_state", [new_state])

	if state != new_state:
		state = new_state


func get_outer_radius()->float:
	var scope = Profiler.scope(self, "get_outer_radius", [])

	var half_size = rect_size * 0.5
	var outer_radius = min(half_size.x, half_size.y)
	return outer_radius

func get_inner_radius(outer_radius)->float:
	var scope = Profiler.scope(self, "get_inner_radius", [outer_radius])

	return outer_radius - (outer_radius * hue_ring_size) - (outer_radius * color_lens_size)


func get_center_relative_mouse_position()->Vector2:
	var scope = Profiler.scope(self, "get_center_relative_mouse_position", [])

	var global_rect: = get_global_rect() as Rect2
	var center = global_rect.position + global_rect.size * 0.5
	return center - get_global_mouse_position()

func update_hue()->void :
	var scope = Profiler.scope(self, "update_hue", [])

	var mouse_pos = get_center_relative_mouse_position()
	var delta = mouse_pos.normalized()
	var angle = PI - atan2(delta.y, delta.x)
	set_hue(angle / TAU)
	update()

func update_saturation_value()->void :
	var scope = Profiler.scope(self, "update_saturation_value", [])

	var mouse_pos = get_center_relative_mouse_position()
	var delta = mouse_pos.normalized()

	var global_angle = PI - atan2(delta.y, delta.x)
	var color_angle = hue * TAU
	var local_angle = fposmod(global_angle - color_angle, TAU)

	var outer_radius = get_outer_radius()
	var inner_radius = get_inner_radius(outer_radius)

	var length = mouse_pos.length() / inner_radius
	var cartesian = polar2cartesian(length, local_angle)

	var vert_hue = Vector2.RIGHT
	var vert_sat = Vector2.RIGHT.rotated( - TAU / 3.0)
	var vert_val = Vector2.RIGHT.rotated(2 * - TAU / 3.0)

	var dot_h = cartesian.dot(vert_hue)
	var dot_s = cartesian.dot(vert_sat)
	var dot_v = cartesian.dot(vert_val)

	dot_h = range_lerp(dot_h, - 0.5, 1.0, 0.0, 1.0)
	dot_s = range_lerp(dot_s, - 0.5, 1.0, 0.0, 1.0)
	dot_v = range_lerp(dot_v, - 0.5, 1.0, 0.0, 1.0)

	var plane_hue = vert_hue
	var plane_sat = Vector2.RIGHT
	var plane_val = vert_val

	var hue_from = - 0.5
	var hue_to = 1.0
	var sat_from = - 0.5
	var sat_to = 1.0
	var val_from = - 0.5
	var val_to = 1.0

	if dot_h < 0 and dot_s >= 0:
		plane_val = vert_hue.rotated(PI * 0.5)
		val_from = - vert_val.y
		val_to = vert_val.y
	elif dot_h >= 0 and dot_s < 0:
		plane_val = vert_sat.rotated( - PI * 0.5)
		val_from = - vert_val.y
		val_to = vert_val.y

	if dot_v < 0 and dot_s >= 0:
		plane_sat = vert_val.rotated(PI * 0.5)
		sat_from = - vert_sat.y
		sat_to = vert_sat.y
	elif dot_v >= 0 and dot_s < 0:
		plane_sat = vert_sat.rotated( - PI * 0.5)
		sat_from = - vert_sat.y
		sat_to = vert_sat.y

	dot_h = cartesian.dot(plane_hue)
	dot_s = cartesian.dot(plane_sat)
	dot_v = cartesian.dot(plane_val)

	dot_h = range_lerp(dot_h, hue_from, hue_to, 0.0, 1.0)
	dot_s = range_lerp(dot_s, sat_from, sat_to, 0.0, 1.0)
	dot_v = range_lerp(dot_v, val_from, val_to, 0.0, 1.0)

	dot_h = clamp(dot_h, 0.0, 1.0)
	dot_s = clamp(dot_s, 0.0, 1.0)
	dot_v = clamp(dot_v, 0.0, 1.0)

	var val = 1.0 - dot_v
	var sat = dot_s / val if val > 0.0 else dot_s
	set_saturation(sat)
	set_value(val)
	update()

func update_color()->void :
	var scope = Profiler.scope(self, "update_color", [])

	color = Color.from_hsv(hue, saturation, value)

func update_size()->void :
	var scope = Profiler.scope(self, "update_size", [])

	$TextureRect.material.set_shader_param("ring_size", hue_ring_size)


func _enter_tree()->void :
	var scope = Profiler.scope(self, "_enter_tree", [])

	connect("resized", self, "resized")

	call_deferred("update_color")
	call_deferred("update_size")
	call_deferred("update")

func _exit_tree()->void :
	var scope = Profiler.scope(self, "_exit_tree", [])

	disconnect("resized", self, "resized")

func wrap(value:float, lower:float, upper:float)->float:
	var scope = Profiler.scope(self, "wrap", [value, lower, upper])

	var rangeZero = upper - lower;

	if value >= lower and value <= upper:
		return value;

	return fmod(value, rangeZero) + lower

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	var _hue_norm = _hue - 0.5
	var hue_norm = hue - 0.5

	var diff = hue_norm - _hue_norm
	if abs(diff) > 0.5:
		if diff > 0:
			_hue_norm += 1.0
		elif diff < 0:
			hue_norm += 1.0

	diff = hue_norm - _hue_norm

	_hue += diff * clamp(delta * LERP_SPEED, 0.0, 1.0)
	if _hue >= 1.0:
		_hue -= 1.0
	elif _hue <= 0.0:
		_hue += 1.0

	_saturation = lerp(_saturation, saturation, clamp(delta * LERP_SPEED, 0.0, 1.0))
	_value = lerp(_value, value, clamp(delta * LERP_SPEED, 0.0, 1.0))
	update()

func _draw()->void :
	var scope = Profiler.scope(self, "_draw", [])

	var global_rect = get_global_rect()
	var center = global_rect.position + global_rect.size * 0.5
	center = center - get_global_rect().position
	var dir = Vector2.RIGHT.rotated(_hue * - TAU)

	var outer_radius = get_outer_radius()
	var inner_radius = get_inner_radius(outer_radius)

	var vh = Vector2.RIGHT
	var vs = Vector2.RIGHT.rotated( - TAU / 3)
	var vv = Vector2.RIGHT.rotated(2 * - TAU / 3)

	
	var points = PoolVector2Array([
		center + inner_radius * vh.rotated(_hue * - TAU), 
		center + inner_radius * vv.rotated(_hue * - TAU), 
		center + inner_radius * vs.rotated(_hue * - TAU), 
	])
	var colors = PoolColorArray([
		angle_to_hue(_hue * TAU), 
		Color.white, 
		Color.black
	])
	draw_polygon(points, colors, PoolVector2Array(), null, null, true)

	
	var line_end = outer_radius - 1
	var line_start = inner_radius - 1
	line_start += line_end * color_lens_size

	draw_line(center + dir * line_start, center + dir * line_end, angle_to_hue(PI + _hue * TAU), 1.5, true)

	
	sv_position.x = lerp(vv.x, vh.x, _saturation * _value)

	var la = lerp(vs.y, vv.y, _value)
	var lb = lerp(vs.y, vh.y, _value)
	sv_position.y = lerp(la, lb, _saturation)

	var position = center + sv_position.rotated(_hue * - TAU) * inner_radius
	var radius = (outer_radius * color_lens_size) - 1
	var point_count = 16
	draw_circle(position, radius, color)
	for i in range(0, point_count):
		var t0 = float(i) / float(point_count)
		var t1 = float(i + 1) / float(point_count)
		var v0 = position + Vector2.UP.rotated(t0 * TAU) * radius
		var v1 = position + Vector2.UP.rotated(t1 * TAU) * radius
		draw_line(v0, v1, color.inverted(), 1.0, true)


func resized()->void :
	var scope = Profiler.scope(self, "resized", [])

	update_size()

func _gui_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_gui_input", [event])

	match state:
		State.IDLE:
			if event is InputEventMouseButton:
				if event.button_index == BUTTON_LEFT and event.pressed:
					var mouse_pos = get_center_relative_mouse_position()

					var outer_radius = get_outer_radius()
					var inner_radius = get_inner_radius(outer_radius)

					if mouse_pos.length() < inner_radius + (outer_radius * color_lens_size):
						set_state(State.SATURATION_VALUE)
						check_saturation_value_change(event)
					elif mouse_pos.length() < outer_radius:
						set_state(State.HUE)
						check_hue_change(event)
		State.HUE:
			check_hue_change(event)
			check_mouse_release(event)
		State.SATURATION_VALUE:
			check_saturation_value_change(event)
			check_mouse_release(event)

func _unhandled_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	match state:
		State.HUE:
			check_mouse_release(event)
		State.SATURATION_VALUE:
			check_mouse_release(event)

func check_hue_change(event:InputEvent)->void :
	var scope = Profiler.scope(self, "check_hue_change", [event])

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		update_hue()
		emit_signal("color_changed", color)

func check_saturation_value_change(event:InputEvent)->void :
	var scope = Profiler.scope(self, "check_saturation_value_change", [event])

	if event is InputEventMouseButton or event is InputEventMouseMotion:
		update_saturation_value()
		emit_signal("color_changed", color)

func check_mouse_release(event:InputEvent)->void :
	var scope = Profiler.scope(self, "check_mouse_release", [event])

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and not event.pressed:
			set_state(State.IDLE)
			emit_signal("color_committed", color)


static func angle_to_hue(angle:float)->Color:
	angle /= TAU
	var color_vec = clamp_vec3(
		(
			(
				fract_vec3(
					Vector3(angle, angle, angle)
					 + Vector3(3.0, 2.0, 1.0)
					 / Vector3(3.0, 3.0, 3.0)
				)
				 * Vector3(6.0, 6.0, 6.0)
				- Vector3(3.0, 3.0, 3.0)
			).abs()
			- Vector3(1.0, 1.0, 1.0)
		), 
		0.0, 
		1.0
	)
	return Color(
		color_vec.x, 
		color_vec.y, 
		color_vec.z, 
		1.0
	)

static func fract_vec3(v:Vector3)->Vector3:
	return Vector3(
		v.x - floor(v.x), 
		v.y - floor(v.y), 
		v.z - floor(v.z)
	)

static func clamp_vec3(v:Vector3, a:float, b:float)->Vector3:
	return Vector3(
		clamp(v.x, a, b), 
		clamp(v.y, a, b), 
		clamp(v.z, a, b)
	)
