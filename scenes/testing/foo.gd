extends Node2D
tool 

enum Foo{
	BAR, 
	BAZ, 
	DECAFISBAD
}

var foo_array
var flags_array

func _get_property_list()->Array:
	return [
		{
			"name":"flags_array", 
			"type":TYPE_ARRAY, 
			"hint":PropertyUtil.PROPERTY_HINT_TYPE_STRING, 
			"hint_string":PropertyUtil.flags_array_hint_string(["Foo", "Bar", "Baz"])
		}, 
		{
			"name":"foo_array", 
			"type":TYPE_ARRAY, 
			"hint":PropertyUtil.PROPERTY_HINT_TYPE_STRING, 
			"hint_string":PropertyUtil.enum_array_hint_string(Foo)
		}
	]
