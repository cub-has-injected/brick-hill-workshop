extends Label

export (int) var window_size: = 15

var _window: = []

func _init()->void :
	_window.clear()
	for i in range(0, window_size):
		_window.append(0.0)

func _process(delta:float)->void :
	_window.append(delta)
	if _window.size() > window_size:
		_window.remove(0)

	var avg = _window[0]
	for i in range(1, window_size):
		avg += _window[i]

	if window_size > 1:
		avg /= window_size


	if avg > 0:
		var fps = 1.0 / avg
		text = "%s" % [round(fps)]
