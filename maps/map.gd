## Resource representing a rhythm game level.
@tool
class_name Map
extends Resource


## Song/audio for the level.
@export var audio: AudioStream
## Creator(s) of the song/audio.
@export var artist: String
## Title of the song/audio.
@export var song_name: String
## Creator(s) of the rhythm game level.
@export var mapper: String
## Type of level.
@export var game_mode: String
## List of timing points that help track the tempo.
@export var timing_points: Array[TimingPoint]:
	set(new_timing_points):
		for index in new_timing_points.size():
			if new_timing_points[index] == null:
				new_timing_points[index] = TimingPoint.new()
		timing_points = new_timing_points
## List of hit objects in the level.
@export var hit_objects: Array[HitObject]:
	set(new_hit_objects):
		for index in new_hit_objects.size():
			if new_hit_objects[index] == null:
				new_hit_objects[index] = HitObject.new()
		hit_objects = new_hit_objects
