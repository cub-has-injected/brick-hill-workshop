class_name UpdateInfo

export (String) var tag:String
export (String) var created_at:String

var channel:String
var local: = false
var site: = false

var downloading: = false
var bytes_downloaded: = 0
var bytes_total: = 1

func set_progress(bytes:int, total:int)->void :
	var scope = Profiler.scope(self, "set_progress", [bytes, total])

	if total <= 0:
		bytes_downloaded = 0
		bytes_total = 1
	else :
		bytes_downloaded = bytes
		bytes_total = total

func progress()->float:
	var scope = Profiler.scope(self, "progress", [])

	if local:
		return 1.0
	else :
		return float(bytes_downloaded) / float(bytes_total)


static func parse_iso_date(iso_date:String)->Dictionary:
	var date: = iso_date.split("T")[0].split("-")
	var time: = iso_date.split("T")[1].split("+")[0].trim_suffix("Z").split(":")

	return {
		year = date[0], 
		month = date[1], 
		day = date[2], 
		hour = time[0], 
		minute = time[1], 
		second = time[2], 
	}
