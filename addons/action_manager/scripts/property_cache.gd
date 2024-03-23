class_name PropertyCache

var cached_properties: = {}

func _init(object:Object, filter:PoolStringArray = PoolStringArray())->void :
	var scope = Profiler.scope(self, "_init", [object, filter])

	for property in object.get_property_list():
		if filter.empty() or property.name in filter:
			cached_properties[property.name] = object[property.name]

func apply(object:Object)->void :
	var scope = Profiler.scope(self, "apply", [object])

	for property in cached_properties:
		object[property] = cached_properties[property]
