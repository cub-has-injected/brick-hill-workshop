"\nInterface for updating the resize proxy on mouse-over\n"

class_name InterfaceResizeProxyControl
extends Interface
tool 

static func name()->String:
	return "InterfaceResizeProxyControl"

static func is_implementor(node:Object)->bool:
	if not node is CollisionObject:
		return false

	for child in node.get_children():
		if child is ResizeProxyControl and not child.has_meta("is_queued_for_remove"):
			return true
	return false

static func get_resize_proxy_control(node:Object)->ResizeProxyControl:
	assert (is_implementor(node))
	for child in node.get_children():
		if child is ResizeProxyControl:
			return child

	return null
