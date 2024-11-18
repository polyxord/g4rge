## Converts a JSON-formatted Quaver map into a [Map] resource. Note 1: You need
## to convert a .qua file to a .json first before using this. Note 2: The audio
## stream of a converted [Map] must be manually assigned afterwards.
@tool
extends EditorScript


# Replace "res://maps/rat.json" with the path to your own converted .json file,
# then do [File > Run] to execute this function.
func _run() -> void:
	var file_name := "res://maps/rat.json"
	if not FileAccess.file_exists(file_name):
		print("File does not exist!")
		return
	
	if file_name.get_extension().to_lower() != "json":
		print("File is not JSON!")
		return
	
	var map := Map.new()
	var json_file := load(file_name) as JSON
	var map_data: Dictionary = json_file.data
	map.game_mode = "%dk" % int(map_data["Mode"])
	map.artist = map_data["Artist"]
	map.song_name = map_data["Title"]
	map.mapper = map_data["Creator"]
	
	var hit_objects: Array[HitObject] = []
	for hit_object_data in map_data["HitObjects"]:
		var hit_object := HitObject.new()
		hit_object.start_time = (
				hit_object_data["StartTime"]
				if hit_object_data.has("StartTime")
				else 0
		)
		hit_object.end_time = (
				hit_object_data["EndTime"]
				if hit_object_data.has("EndTime")
				else 0
		)
		hit_object.lane = hit_object_data["Lane"]
		hit_objects.append(hit_object)
	map.hit_objects = hit_objects
	
	var timing_points: Array[TimingPoint] = []
	for timing_point_data in map_data["TimingPoints"]:
		var timing_point := TimingPoint.new()
		timing_point.time = (
				timing_point_data["StartTime"] 
				if timing_point_data.has("StartTime")
				else 0
		)
		timing_point.bpm = timing_point_data["Bpm"]
		timing_points.append(timing_point)
	map.timing_points = timing_points
	
	ResourceSaver.save(map, file_name.get_basename() + ".tres")
