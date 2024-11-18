## Resource representing an object to be hit at a certain time in a song.
class_name HitObject
extends Resource


## Start time in milliseconds.
@export var start_time: int
## End time in milliseconds.
@export var end_time: int
## Lane number.
@export_range(1, 10) var lane: int = 1
