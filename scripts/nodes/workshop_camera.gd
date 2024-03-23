class_name WorkshopCamera
extends BrickHillCamera

signal zoom_changed(zoom_scalar)
signal move_speed_changed(move_speed_scalar)
signal capture_mouse()
signal release_mouse()

export (float) var zoom: = 20.0 setget set_zoom
export (float) var move_speed: = 10.0 setget set_move_speed

export (float) var focus_speed: = 5.0
export (Curve) var focus_curve

const HALF_PI = PI * 0.5

const MIN_ZOOM: = 0.0
const MAX_ZOOM: = 100.0
const ZOOM_DELTA: = 2.0

const MIN_SPEED: = 1.0
const MAX_SPEED: = 100.0
const SPEED_DELTA: = 2.0

var yaw: = 0.0
var pitch: = 0.0

var focusing: = false
var focus_from: = Vector3.ZERO
var focus_to: = Vector3.ZERO
var focus_progress: = 0.0

var input_dict: = {
	"move_forward":false, 
	"move_backward":false, 
	"move_left":false, 
	"move_right":false, 
	"move_up":false, 
	"move_down":false, 
}

func set_zoom(new_zoom:float)->void :
	var scope = Profiler.scope(self, "set_zoom", [new_zoom])

	if zoom != new_zoom:
		zoom = new_zoom
		if is_inside_tree():
			update_zoom()

func set_move_speed(new_move_speed:float)->void :
	var scope = Profiler.scope(self, "set_move_speed", [new_move_speed])

	if move_speed != new_move_speed:
		move_speed = new_move_speed
		if is_inside_tree():
			update_move_speed()

func _ready()->void :
	var scope = Profiler.scope(self, "_ready", [])

	pitch = rotation.x
	yaw = rotation.y

func update_zoom()->void :
	var scope = Profiler.scope(self, "update_zoom", [])

	emit_signal("zoom_changed", range_lerp(zoom, MIN_ZOOM, MAX_ZOOM, 0.0, 1.0))

func update_move_speed()->void :
	var scope = Profiler.scope(self, "update_move_speed", [])

	emit_signal("move_speed_changed", range_lerp(move_speed, MIN_SPEED, MAX_SPEED, 0.0, 1.0))

func _process(delta:float)->void :
	var scope = Profiler.scope(self, "_process", [delta])

	if focusing:
		var progress = focus_progress + delta * focus_speed
		focus_progress = min(progress, 1.0)
		translation = lerp(focus_from, focus_to, focus_curve.interpolate(progress))
		if focus_progress == 1.0:
			focusing = false
	else :
		
		var wish_vector = Vector3.ZERO

		wish_vector -= global_transform.basis.x if input_dict["move_left"] else Vector3.ZERO
		wish_vector += global_transform.basis.x if input_dict["move_right"] else Vector3.ZERO
		wish_vector += global_transform.basis.y if input_dict["move_up"] else Vector3.ZERO
		wish_vector -= global_transform.basis.y if input_dict["move_down"] else Vector3.ZERO
		wish_vector -= global_transform.basis.z if input_dict["move_forward"] else Vector3.ZERO
		wish_vector += global_transform.basis.z if input_dict["move_backward"] else Vector3.ZERO

		translation += wish_vector * move_speed * delta

func focus_position(position:Vector3)->void :
	var scope = Profiler.scope(self, "focus_position", [position])

	focus_from = translation
	focus_to = position + transform.basis.z * zoom
	focus_progress = 0.0
	focusing = true

func change_move_speed(delta:float)->void :
	var scope = Profiler.scope(self, "change_move_speed", [delta])

	if move_speed + delta <= MIN_SPEED:
		delta = MIN_SPEED - move_speed
	elif move_speed + delta >= MAX_SPEED:
		delta = MAX_SPEED - move_speed

	set_move_speed(move_speed + delta)

func increment_move_speed()->void :
	var scope = Profiler.scope(self, "increment_move_speed", [])

	change_move_speed(SPEED_DELTA)

func decrement_move_speed()->void :
	var scope = Profiler.scope(self, "decrement_move_speed", [])

	change_move_speed( - SPEED_DELTA)

func _unhandled_input(event:InputEvent)->void :
	var scope = Profiler.scope(self, "_unhandled_input", [event])

	if self != get_viewport().get_camera():
		return 

	if focusing:
		return 

	if event is InputEventKey:
		test_action(event, "move_forward")
		test_action(event, "move_backward")
		test_action(event, "move_left")
		test_action(event, "move_right")
		test_action(event, "move_up")
		test_action(event, "move_down")
		return 

	if not event is InputEventMouseButton and not event is InputEventMouseMotion:
		return 

	var left_mouse_down = BUTTON_MASK_LEFT & event.button_mask == BUTTON_MASK_LEFT
	var right_mouse_down = BUTTON_MASK_RIGHT & event.button_mask == BUTTON_MASK_RIGHT
	var middle_mouse_down = BUTTON_MASK_MIDDLE & event.button_mask == BUTTON_MASK_MIDDLE

	if left_mouse_down:
		return 

	if event is InputEventMouseButton:
		if right_mouse_down or middle_mouse_down:
			emit_signal("capture_mouse")
		else :
			emit_signal("release_mouse")

		if right_mouse_down:
			var delta_speed = 0
			if event.pressed and event.button_index == BUTTON_WHEEL_UP:
				delta_speed = SPEED_DELTA
			elif event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
				delta_speed = - SPEED_DELTA

			change_move_speed(delta_speed)

		else :
			var delta_zoom = 0
			if event.pressed and event.button_index == BUTTON_WHEEL_UP:
				delta_zoom = - ZOOM_DELTA
			elif event.pressed and event.button_index == BUTTON_WHEEL_DOWN:
				delta_zoom = ZOOM_DELTA

			if zoom + delta_zoom <= MIN_ZOOM:
				delta_zoom = MIN_ZOOM - zoom
			elif zoom + delta_zoom >= MAX_ZOOM:
				delta_zoom = MAX_ZOOM - zoom

			set_zoom(zoom + delta_zoom)
			global_transform.origin += global_transform.basis.z * delta_zoom
	elif event is InputEventMouseMotion:
		var inv_scale = 1.0 / GraphicsSettings.data.resolution_scale_factor
		var delta_yaw = event.relative.x * inv_scale * - 0.002
		var delta_pitch = event.relative.y * inv_scale * - 0.002

		var new_pitch = pitch + delta_pitch
		if abs(new_pitch) > HALF_PI:
			delta_pitch -= (abs(new_pitch) - HALF_PI) * sign(new_pitch)

		if right_mouse_down:
			yaw += delta_yaw
			pitch += delta_pitch
		elif middle_mouse_down:
			var origin = global_transform.origin - global_transform.basis.z * zoom
			var relative = global_transform.origin - origin
			relative = relative.rotated(Vector3.UP, delta_yaw)
			relative = relative.rotated(global_transform.basis.x, delta_pitch)
			global_transform.origin = origin + relative
			yaw += delta_yaw
			pitch += delta_pitch

		self.rotation = Vector3.ZERO
		rotate(Vector3.UP, yaw)
		rotate(global_transform.basis.x, pitch)

func test_action(event:InputEvent, action_name:String)->void :
	var scope = Profiler.scope(self, "test_action", [event, action_name])

	if event.is_action(action_name):
		input_dict[action_name] = event.pressed

func clear_input()->void :
	var scope = Profiler.scope(self, "clear_input", [])

	for key in input_dict:
		input_dict[key] = false
