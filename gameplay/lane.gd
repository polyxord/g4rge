class_name Lane
extends Control


var note_queue: Array[Note] = []
var next_note_to_add_index: int
var hit_lighting_tween: Tween

@onready var hit_lighting: TextureRect = %HitLighting


func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	hit_lighting.modulate.a = 0.0
