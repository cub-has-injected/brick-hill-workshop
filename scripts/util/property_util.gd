class_name PropertyUtil


const PROPERTY_HINT_OBJECT_ID = 23
const PROPERTY_HINT_TYPE_STRING = 24
const PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE = 25
const PROPERTY_HINT_METHOD_OF_VARIANT_TYPE = 26
const PROPERTY_HINT_METHOD_OF_BASE_TYPE = 27
const PROPERTY_HINT_METHOD_OF_INSTANCE = 28
const PROPERTY_HINT_METHOD_OF_SCRIPT = 29
const PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE = 30
const PROPERTY_HINT_PROPERTY_OF_BASE_TYPE = 31
const PROPERTY_HINT_PROPERTY_OF_INSTANCE = 32
const PROPERTY_HINT_PROPERTY_OF_SCRIPT = 33
const PROPERTY_HINT_OBJECT_TOO_BIG = 34
const PROPERTY_HINT_NODE_PATH_VALID_TYPES = 35
const PROPERTY_HINT_SAVE_FILE = 36
const PROPERTY_HINT_MAX = 37

class InspectorCategory:
	var name:String
	var properties:Array

	func _init(in_name:String, in_properties:Array):
		name = in_name
		properties = in_properties.duplicate()

class InspectorProperty:
	var name:String
	var type:int
	var hint:int
	var hint_string:String

	func _init(in_name:String, in_type:int, in_hint:int = - 1, in_hint_string:String = "")->void :
		name = in_name
		type = in_type
		hint = in_hint
		hint_string = in_hint_string

	func get_dict()->Dictionary:
		return {
			"name":name, 
			"type":type, 
			"hint":hint, 
			"hint_string":hint_string
		}

static func parse_properties(inspector_categories:Array)->Array:
	var properties: = []

	var category_names: = PoolStringArray()
	var category_properties: = {}

	for category in inspector_categories:
		if not category.name in category_names:
			category_names.append(category.name)

		if not category.name in category_properties:
			category_properties[category.name] = []

		for property in category.properties:
			category_properties[category.name].append(property.get_dict())

	for category_name in category_names:
		properties.append({
			"name":category_name, 
			"type":TYPE_STRING, 
			"usage":PROPERTY_USAGE_CATEGORY
		})

		for property in category_properties[category_name]:
			properties.append(property)

	return properties

static func enum_array_hint_string(enumeration:Dictionary)->String:
	var enum_string: = ""
	for key in enumeration:
		enum_string += "%s:%s" % [key.capitalize(), enumeration[key]]
		if key != enumeration.keys().back():
			enum_string += ","
	return array_hint_string(TYPE_INT, PROPERTY_HINT_ENUM, enum_string)

static func flags_array_hint_string(flags:PoolStringArray)->String:
	return array_hint_string(TYPE_INT, PROPERTY_HINT_FLAGS, flags.join(","))

static func array_hint_string(base_type:int, sub_type:int, hint_string)->String:
	return "%s/%s:%s" % [base_type, sub_type, hint_string]

static func enum_to_hint_string(enumeration:Dictionary)->String:
	var out_string: = ""
	for key in enumeration:
		out_string += key.capitalize()
		if key != enumeration.keys().back():
			out_string += ","
	return out_string
