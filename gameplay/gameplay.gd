class_name Gameplay
extends Control


const _NOTE := preload("res://gameplay/note.tscn")
const _LANE := preload("res://gameplay/lane.tscn")
const _HIT_EFFECT_1 = preload("res://gameplay/hit_effect_1.tscn")
const _LANE_WIDTH := 60
const _HIT_RECEPTOR_Y_OFFSET := 40
const _MS_LOAD_THRESHOLD := 2000
const _HIT_ERROR_COLOR := Color.ORANGE

@export var map: Map

var _audio_offset: int
var _scroll_speed_factor: float
var _num_lanes: int
var _lane_action_names: PackedStringArray = []
var _physics_process_current_song_time: float
#var _process_current_song_time: float
var _lanes: Array[Lane] = []
var _judgements: Array[Dictionary] = [
	{"time" = 18, "text" = ""},
	{"time" = 43, "text" = "Perfect"},
	{"time" = 76, "text" = "Great"},
	{"time" = 106, "text" = "Good"},
	{"time" = 127, "text" = "Bad"},
	{"time" = 164, "text" = "Miss"},
]
var _last_judgement_threshold: int
var _judgement_tween: Tween
var _hit_combo := 0:
	set(new_combo):
		_hit_combo = new_combo
		_combo_label.text = (
				""
				if new_combo == 0
				else str(new_combo)
		)
var _hit_error_size: Vector2
var _hit_error_x_offset: float
var _is_hit_lighting_enabled := true
var _is_hit_particles_enabled := true
var _is_early_miss_window_disabled := true

@onready var _spacer: Control = %Spacer
@onready var _lanes_h_box_container: Control = %LanesHBoxContainer
@onready var _audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var _level_end_timer: Timer = %LevelEndTimer
@onready var _pause_menu: PauseMenu = %PauseMenu
@onready var _combo_label: Label = %ComboLabel
@onready var _judgement_label: Label = %JudgementLabel
@onready var _hit_error_bar: ColorRect = %HitErrorBar
@onready var _playfield: Control = %Playfield


func _ready() -> void:
	_judgement_label.text = ""
	_combo_label.text = ""
	_pause_menu.map_to_retry = map
	_last_judgement_threshold = _judgements[-1]["time"]
	var gameplay_settings := ConfigHandler.load_settings("gameplay")
	_audio_offset = gameplay_settings.audio_offset
	_audio_offset += int(AudioServer.get_output_latency())
	_scroll_speed_factor = gameplay_settings.scroll_speed / 30.0
	_num_lanes = int(map.game_mode)
	_lanes_h_box_container.custom_minimum_size.x = _num_lanes * _LANE_WIDTH
	_spacer.custom_minimum_size.y = _HIT_RECEPTOR_Y_OFFSET
	_hit_error_size = _hit_error_bar.size
	_hit_error_size.x /= 2.0
	_hit_error_x_offset = _hit_error_bar.size.x / 4.0
	
	# Set up note colors depending on lane number.
	var lane_note_colors: Array[Color] = []
	var is_odd_num_lanes := _num_lanes % 2 == 1
	var temp_num_lanes := (
			_num_lanes
			if is_odd_num_lanes 
			else _num_lanes + 1
	)
	var temp_middle_lane := int((temp_num_lanes + 1) / 2.0)
	# Currently implements colors similar to YaLTeR's skin on Quaver.
	for lane_num in range(1, temp_num_lanes + 1):
		if lane_num == temp_middle_lane:
			if is_odd_num_lanes:
				lane_note_colors.append(Color.GOLD)
		elif lane_num % 2 == 1:
			lane_note_colors.append(Color.WHITE)
		else:
			lane_note_colors.append(Color.HOT_PINK)
	
	# Prepare lanes.
	for lane_idx in range(_num_lanes):
		var lane := _LANE.instantiate() as Lane
		_lanes_h_box_container.add_child(lane)
		_lanes.append(lane)
		if lane.hit_lighting.texture is not GradientTexture2D:
			continue
		
		var hit_lighting_texture := lane.hit_lighting.texture as GradientTexture2D
		# Don't know why this doesn't work when _LANE_WIDTH < 60.
		# Works in all other cases.
		hit_lighting_texture.width = _LANE_WIDTH
	
	# Set up note queues.
	var note: Note
	for hit_object in map.hit_objects:
		note = _NOTE.instantiate() as Note
		note.scale *= _LANE_WIDTH / 60.0 #note.color_rect.size.x
		note.info = hit_object
		var lane := hit_object.lane
		note.modulate = lane_note_colors[lane - 1]
		_lanes[lane - 1].note_queue.append(note)
	# Start the level end timer when last note is exiting the tree.
	note.tree_exiting.connect(_level_end_timer.start)
	for lane in _lanes:
		lane.note_queue.reverse()
		lane.next_note_to_add_index = lane.note_queue.size() - 1
	
	# Set up InputMap.
	var keybind_settings := ConfigHandler.load_settings("keybinds")
	var keybind_str: String = keybind_settings[map.game_mode]
	var lane_keybinds := keybind_str.split(" ")
	for lane_idx in _num_lanes:
		var lane_action_name := "lane_%s" % (lane_idx + 1)
		_lane_action_names.append(lane_action_name)
		InputMap.action_erase_events(lane_action_name)
		var lane_keybind := lane_keybinds[lane_idx]
		var event := InputEventKey.new()
		event.keycode = OS.find_keycode_from_string(lane_keybind)
		InputMap.action_add_event(lane_action_name, event)
	
	var scroll_direction: String = gameplay_settings.scroll_direction
	if scroll_direction == "Down":
		_playfield.scale.y = -1.0
		_playfield.anchor_top = 1.0
		_playfield.anchor_bottom = 2.0
	elif scroll_direction == "Up":
		_playfield.scale.y = 1.0
		_playfield.anchor_top = 0.0
		_playfield.anchor_bottom = 1.0
	
	var goto_rat := func() -> void:
		SceneHandler.goto_scene("res://menus/rat_menu.tscn")
	_level_end_timer.timeout.connect(goto_rat)
	_level_end_timer.tree_exited.connect(func() -> void:
		_level_end_timer.timeout.disconnect(goto_rat)
	)
	
	_audio_stream_player.stream = map.audio
	_audio_stream_player.play()


#func _process(delta: float) -> void:
	#var audio_time := _audio_stream_player.get_playback_position()
	#_process_current_song_time = maxf(audio_time, _process_current_song_time + delta)
	#var unrounded_ms_song_time := 1000 * _process_current_song_time - _audio_offset
	#for lane in _lanes:
		## Update note positions
		#var lane_note_queue := lane.note_queue 
		#var start_idx := maxi(0, lane.next_note_to_add_index)
		#for idx in range(start_idx, lane_note_queue.size()):
			#var note := lane_note_queue[idx]
			#var time_difference := note.info.start_time - unrounded_ms_song_time
			#var receptor_offset := time_difference * _scroll_speed_factor
			#note.position.y = receptor_offset


func _physics_process(delta: float) -> void:
	var audio_time := _audio_stream_player.get_playback_position()
	_physics_process_current_song_time = maxf(audio_time, _physics_process_current_song_time + delta)
	var unrounded_ms_song_time := 1000 * _physics_process_current_song_time - _audio_offset
	var rounded_ms_song_time := roundi(unrounded_ms_song_time)
	var ms_load_time_threshold := rounded_ms_song_time + _MS_LOAD_THRESHOLD
	var ms_miss_time_threshold := rounded_ms_song_time - _last_judgement_threshold
	
	for lane in _lanes:
		var lane_note_queue := lane.note_queue 
		# Remove missed notes that weren't hit on time.
		while (
				not lane.note_queue.is_empty()
				and lane.note_queue[-1].info.start_time <= ms_miss_time_threshold
		):
			lane.note_queue[-1].queue_free()
			lane_note_queue.resize(lane_note_queue.size() - 1)
			_set_judgement_text("Miss")
			_hit_combo = 0
		
		# Move notes from queue into lanes.
		while (
				lane.next_note_to_add_index >= 0
				and lane_note_queue[lane.next_note_to_add_index].info.start_time <= ms_load_time_threshold
		):
			var new_note := lane_note_queue[lane.next_note_to_add_index]
			lane.add_child(new_note)
			lane.next_note_to_add_index -= 1
		
		# Update note positions
		var start_idx := maxi(0, lane.next_note_to_add_index)
		for idx in range(start_idx, lane_note_queue.size()):
			var note := lane_note_queue[idx]
			var time_difference := note.info.start_time - unrounded_ms_song_time
			var distance_to_receptor := time_difference * _scroll_speed_factor
			note.position.y = distance_to_receptor
	
	# Hit notes
	for action in _lane_action_names:
		var lane_num := int(action)
		var lane := _lanes[lane_num - 1]
		if Input.is_action_just_pressed(action):
			if _is_hit_lighting_enabled:
				var hit_lighting := lane.hit_lighting
				if lane.hit_lighting_tween:
					lane.hit_lighting_tween.kill()
				hit_lighting.modulate.a = 0.8
			
			if lane.note_queue.is_empty():
				continue
			
			var early_miss_time_threshold := -_last_judgement_threshold
			var current_note := lane.note_queue[-1]
			var time_from_note := rounded_ms_song_time - current_note.info.start_time
			if time_from_note < early_miss_time_threshold:
				continue
			
			var judgement := "Ghost Tap"
			var abs_time_from_note := absi(time_from_note)
			for this_judgement in _judgements:
				if abs_time_from_note < this_judgement["time"]:
					judgement = this_judgement["text"]
					break
			
			if (
					_is_early_miss_window_disabled
					and judgement == "Miss"
					and time_from_note < 0
			):
				continue
			
			_set_judgement_text(judgement)
			_hit_combo = 0 if judgement == "Miss" else _hit_combo + 1
			
			var hit_error := ColorRect.new()
			hit_error.modulate = _HIT_ERROR_COLOR
			hit_error.size = _hit_error_size
			hit_error.position.x = 1.5 * time_from_note + _hit_error_x_offset
			_hit_error_bar.add_child(hit_error)
			var hit_error_fade := create_tween().set_ease(Tween.EASE_IN)
			hit_error_fade.tween_property(hit_error, "modulate:a", 0.0, 0.5)
			hit_error_fade.finished.connect(hit_error.queue_free)
			
			var note_to_remove := lane.note_queue[-1]
			note_to_remove.queue_free()
			lane.note_queue.resize(lane.note_queue.size() - 1)
			
			if _is_hit_particles_enabled:
				var particles := _HIT_EFFECT_1.instantiate() as GPUParticles2D
				particles.position = note_to_remove.position
				particles.position.x += note_to_remove.color_rect.size.x / 2.0
				lane.add_child(particles)
				particles.finished.connect(particles.queue_free)
				particles.emitting = true
			
		elif Input.is_action_just_released(action):
			if not _is_hit_lighting_enabled:
				continue
				
			if lane.hit_lighting_tween:
				lane.hit_lighting_tween.kill()
			lane.hit_lighting_tween = create_tween()
			lane.hit_lighting_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			lane.hit_lighting_tween.tween_property(lane.hit_lighting, "modulate:a", 0.0, 0.1)


func _set_judgement_text(judgement: String) -> void:
	if _judgement_tween:
		_judgement_tween.kill() 
	_judgement_label.text = judgement
	_judgement_label.modulate.a = 1.0
	_judgement_tween = create_tween()
	_judgement_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_judgement_tween.tween_property(_judgement_label, "modulate:a", 0.0, 0.25)
