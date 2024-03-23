class_name JobSystem
tool 

signal jobs_finished(results)

enum WorkMode{
	THREADS = 0, 
	LOOP = 1
}

var work_mode = WorkMode.THREADS

var job_count: = - 1
var job_results:Dictionary
var threads:Array

func _init()->void :
	var scope = Profiler.scope(self, "_init", [])

	job_results = {}
	threads = []

func reset_state()->void :
	var scope = Profiler.scope(self, "reset_state", [])

	threads.clear()
	job_count = - 1
	job_results.clear()

func run_job_single(instance:Object, function:String, userdata:Dictionary)->void :
	var scope = Profiler.scope(self, "run_job_single", [instance, function, userdata])

	if job_count != - 1:
		printerr("Previous jobs still running")
		return 

	reset_state()

	job_count = 1

	var userdata_copy = userdata.duplicate()
	userdata_copy["job_index"] = 0

	match work_mode:
		WorkMode.THREADS:
			var thread = Thread.new()
			threads.append(thread)
			var thread_start_error = thread.start(instance, function, userdata_copy)
			if thread_start_error:
				printerr("Thread start error: %s" % [BrickHillUtil.get_error_string(thread_start_error)])
				return 
		WorkMode.LOOP:
			job_results[0] = instance.call(function, userdata_copy)

func run_jobs_array_each(instance:Object, function:String, size:int, userdata:Dictionary)->void :
	var scope = Profiler.scope(self, "run_jobs_array_each", [instance, function, size, userdata])

	if job_count != - 1:
		printerr("Previous jobs still running")
		return 

	reset_state()

	job_count = size

	var iter = range(0, job_count)
	for i in iter:
		var userdata_copy = userdata.duplicate()
		userdata_copy["job_index"] = i

		match work_mode:
			WorkMode.THREADS:
				var thread = Thread.new()
				threads.append(thread)
				thread.start(instance, function, userdata_copy)
			WorkMode.LOOP:
				job_results[i] = instance.call(function, userdata_copy)

func run_jobs_array_spread(instance:Object, function:String, size:int, userdata:Dictionary)->void :
	var scope = Profiler.scope(self, "run_jobs_array_spread", [instance, function, size, userdata])

	if job_count != - 1:
		printerr("Previous jobs still running")
		return 

	reset_state()

	job_count = OS.get_processor_count() - 1
	var chunk_size = size / job_count

	var iter = range(0, job_count)
	for i in iter:
		var userdata_copy = userdata.duplicate()
		userdata_copy["job_index"] = i
		userdata_copy["start"] = i * chunk_size

		if i == iter[ - 1]:
			userdata_copy["end"] = size
		else :
			userdata_copy["end"] = i * chunk_size + chunk_size

		match work_mode:
			WorkMode.THREADS:
				var thread = Thread.new()
				threads.append(thread)
				thread.start(instance, function, userdata_copy)
			WorkMode.LOOP:
				job_results[i] = instance.call(function, userdata_copy)

func job_finished(index:int)->void :
	var scope = Profiler.scope(self, "job_finished", [index])

	if work_mode == WorkMode.THREADS:
		job_results[index] = threads[index].wait_to_finish()

	job_count -= 1
	check_done()

func check_done()->void :
	var scope = Profiler.scope(self, "check_done", [])

	if job_count == 0:
		emit_signal("jobs_finished", job_results)
		reset_state()
