"\nAbstract base class for interfaces\n"

class_name Interface
extends Resource
tool 

static func name()->String:
	return "Interface"

static func group_name()->String:
	var re = RegEx.new()
	re.compile("(?<!^)(?=[A-Z])")
	var group_name = re.sub(name(), "_", true).to_lower()
	return group_name

static func is_implementor(node:Object)->bool:
	return false

func _init()->void :
	if get_name().empty():
		set_name(name())
